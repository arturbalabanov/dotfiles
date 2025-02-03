# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "rich",
#     "typer",
#     "python-dotenv",
#     "fabric",
# ]
# ///

import dataclasses
import textwrap
import rich
from rich.prompt import Prompt
import subprocess
import pathlib
import typer
import dotenv
import os
import copy
import tempfile
from rich.syntax import Syntax
import fabric


# Original bash script:
#
# function repl {
# 	if [[ "$#" -lt 2 ]]; then
# 		echo "usage: $0 <shell> <env> [service=platform]" >&2
# 		return 1
# 	fi
#
# 	shell="$1"
# 	env="$2"
# 	service_name="${3:-platform}"
#
# 	aws_default_region="eu-west-1"
# 	aws_storage_bucket_name="7b-dev-media-$aws_default_region"
#
# 	if [[ $env == "staging" ]]; then
# 		db_url="$(pass show staging_db_url)/staging"
# 		aws_access_key_id="$(pass show staging_aws_access_key_id)"
# 		aws_secret_access_key="$(pass show staging_aws_secret_access_key)"
# 	elif [[ $env =~ "^(kube|review)\-" ]]; then
# 		# Review instance, the platofrm DB name is the same as the container
# 		# (environment)
# 		db_name="$2"
#
# 		db_url="$(pass show staging_db_url)/$db_name"
# 		aws_access_key_id="$(pass show staging_aws_access_key_id)"
# 		aws_secret_access_key="$(pass show staging_aws_secret_access_key)"
# 	elif [[ $env == "prod" ]]; then
# 		db_url="$(pass show prod_db_url)/platform"
# 		aws_access_key_id="$(pass show prod_aws_access_key_id)"
# 		aws_secret_access_key="$(pass show prod_aws_secret_access_key)"
# 	else
# 		echo "invalid environment: $env" >&2
# 		return 1
# 	fi
#
# 	export AWS_DEFAULT_REGION="$aws_default_region"
# 	export AWS_STORAGE_BUCKET_NAME="$aws_storage_bucket_name"
# 	export AWS_ACCESS_KEY_ID="$aws_access_key_id"
# 	export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
#
# 	if [[ $shell == "py" ]]; then
# 		cd ~/dev/sid/seven_bridges
# 		venv
# 		DATABASE_URL="$db_url"  ./manage.py shell_plus
# 	elif [[ $shell == 'pg' || $shell == 'db' || $shell == 'sql' ]]; then
# 		pgcli "$db_url"
# 	else
# 		echo "invalid shell: $shell" >&2
# 		return 1
# 	fi
# }

SWO_PROJECTS = pathlib.Path.home() / "dev" / "software-one"


@dataclasses.dataclass
class Service:
    name: str
    env_prefix: str
    root_dir: pathlib.Path
    main_docker_container_name: str

    def __post_init__(self):
        self._dotfile_env = None

    def get_env_name(self, key: str) -> str:
        if key.startswith(self.env_prefix):
            return key.upper()

        return f"{self.env_prefix.removesuffix('_')}_{key}".upper()

    def get_env_var(self, key: str) -> str:
        if self._dotfile_env is None:
            self.dotfile_env()

        return self._dotfile_env[self.get_env_name(key)]

    def remove_prefix_from_env_var_name(self, env_var_name: str) -> str:
        return env_var_name.removeprefix(
            self.env_prefix.removesuffix("_").upper() + "_"
        )

    def dotfile_env(
        self, file_name: str = ".env", remove_prefix: bool = False
    ) -> dict[str, str]:
        dotenv_values = dotenv.dotenv_values(self.root_dir / file_name)

        if remove_prefix:
            self._dotfile_env = {
                self.remove_prefix_from_env_var_name(key): value
                for key, value in dotenv_values.items()
            }
        else:
            self._dotfile_env = dotenv.dotenv_values(self.root_dir / file_name)

        return self._dotfile_env

    def get_local_db_conn_string(self):
        postgres_user = self.get_env_var("POSTGRES_USER")
        postgres_password = self.get_env_var("POSTGRES_PASSWORD")
        postgres_host = self.get_env_var("POSTGRES_HOST")
        postgres_port = self.get_env_var("POSTGRES_PORT")
        postgres_db = self.get_env_var("POSTGRES_DB")

        return (
            "postgresql://"
            f"{postgres_user}:{postgres_password}"
            f"@{postgres_host}:{postgres_port}"
            f"/{postgres_db}"
        )


all_services = [
    Service(
        name="ffc-finops-operations",
        env_prefix="FFC_OPERATIONS",
        root_dir=SWO_PROJECTS / "mpt-finops-operations",
        main_docker_container_name="ffc-operations",
    )
]

services_by_name = {service.name: service for service in all_services}

PYTHON_SHELL_START_LINES = """
    from app.db.models import *
    from app.db.handlers import *
    from app.db.db import db_engine
    from sqlalchemy.ext.asyncio import (
        AsyncSession,
        async_sessionmaker,
        create_async_engine,
    )

    session = async_sessionmaker(bind=db_engine, class_=AsyncSession, expire_on_commit=False)()
"""

SYNTAX_THEME = "monokai"

console = rich.get_console()

def get_ssh_conn_string_by_env_name(environment: str) -> str:
    # TODO: Add more env support
    assert environment == "dev"

    return "cloudspend@cloudspend.velasuci.com"


def pgcli_shell(service: Service, environment: str = "local"):
    # TODO: Add more env support
    assert environment == "local"

    console.clear()
    subprocess.run(f"pgcli {service.get_local_db_conn_string()}", shell=True)


def python_shell(service: Service, environment: str = "local"):
    # TODO: Add more env support
    assert environment == "local"

    env_vars = copy.deepcopy(os.environ)
    del env_vars["VIRTUAL_ENV"]
    env_vars.update(service.dotfile_env())

    console.clear()

    with tempfile.NamedTemporaryFile("w+", delete_on_close=False) as temp_file:
        start_lines = textwrap.dedent(PYTHON_SHELL_START_LINES).strip()
        temp_file.write(start_lines)
        temp_file.close()

        console.print(Syntax(start_lines, "python", theme=SYNTAX_THEME))
        console.print()

        subprocess.run(
            f"uv run ipython --TerminalInteractiveShell.highlighting_style={SYNTAX_THEME} -i {temp_file.name}",
            shell=True,
            cwd=service.root_dir,
            env=env_vars,
        )


def logs_shell(service: Service, environment: str):
    # TODO: Big hack, not even a repl but good enough for now
    ssh_conn_string = get_ssh_conn_string_by_env_name(environment)
    cmd = rf"""
        echo 'docker logs $(docker ps | grep {service.main_docker_container_name} | awk "{{ print \$NF }}") | less' \
        | ssh {ssh_conn_string} /bin/bash
    """
    cmd = textwrap.dedent(cmd).strip()
    subprocess.run(cmd, shell=True)
    

def docker_shell(service: Service, environment: str):
    ssh_conn_string = get_ssh_conn_string_by_env_name(environment)

    passphrase = Prompt.ask("Enter the passphrase for your encrypted SSH key", password=True)
    with fabric.Connection(ssh_conn_string, connect_kwargs={"passphrase": passphrase}) as conn:
        cmd = rf"""
            docker run -it -v .:/app \
                $(docker images | grep "{service.main_docker_container_name}" | head -1 | awk '{{ print $3 }}') \
                bash
        """

        cmd = textwrap.dedent(cmd).strip()
        conn.run(cmd, pty=True)


def main(shell: str, env: str = "local", service_name: str | None = None):
    if shell not in ["db", "pg", "sql", "py", "python", "ipython", "log", "logs", "docker"]:
        raise ValueError(
            f"invalid shell: {shell}, onlt db / pg / sql / py / python / ipython / log / logs / docker is supported"
        )

    if env != "local":
        if env == "dev":
            if shell not in ['log', 'logs', 'docker']:
                raise ValueError("Only log / logs / docker is supported for dev environment for now")
        else:
            raise ValueError(f"invalid environment: {env}, only local is supported")

    service = None

    if service_name is None:
        current_path = pathlib.Path.cwd().resolve()

        for possible_service in all_services:
            if possible_service.root_dir.resolve() in [
                current_path,
                *current_path.parents,
            ]:
                service = possible_service
                break
        else:
            raise ValueError(
                "not in any service dir, service is required. "
                f"The available services are: {', '.join(services_by_name)}"
            )
    else:
        if service_name not in services_by_name:
            raise ValueError(
                f"invalid service: {service_name}, valid services are {', '.join(services_by_name.keys())}"
            )

        service = services_by_name[service_name]

    assert service is not None

    if shell in ["db", "pg", "sql"]:
        pgcli_shell(service, env)
    elif shell in ["py", "python", "ipython"]:
        python_shell(service, env)
    elif shell in ["log", "logs"]:
        logs_shell(service, env)
    elif shell == 'docker':
        docker_shell(service, env)
    else:
        raise ValueError(
            f"invalid shell: {shell}, only db / pg / sql / py / python / ipython is supported"
        )


# TODO: Quite ambitious but! be able to run a shell with multiple complex dependancies
#       (e.g. a python shell based on the staging build but with the production db and
#        with a dependancy service using a local build with production db)

if __name__ == "__main__":
    typer.run(main)
