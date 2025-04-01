# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "rich",
#     "typer",
#     "jira",
# ]
# ///

import pathlib
from jira import JIRA, Issue
import typer
import re
import json

JIRA_TOKEN_FILE = pathlib.Path.home() / 'tokens' / 'jira.txt'
JIRA_CONFIG_FILE = pathlib.Path.home() / '.local' / 'share' / 'scripts' / 'jira_config.json'
jira_config = json.loads(JIRA_CONFIG_FILE.read_text())

jira = JIRA(
    basic_auth=(
        jira_config["email"],
        JIRA_TOKEN_FILE.read_text().strip(),
    ),
    server=jira_config["server"],
)

def make_default_branch_name(issue: Issue) -> str:
    if issue.fields.issuetype.name == 'Bug':
        branch_prefix = 'fix'
    elif issue.fields.issuetype.name == 'Story':
        branch_prefix = 'feat'
    elif issue.fields.issuetype.name == 'Task':
        branch_prefix = 'chore'
    else:
        raise ValueError(f"Unknown issue type: {issue.fields.issuetype.name}")

    # remove special characters
    branch_summary = re.sub(r'[^\w\s\-_]', '', issue.fields.summary.strip())
    # replace spaces and underscores with dashes
    branch_summary = re.sub(r'[\s\-_]+', '-', branch_summary)

    return f"{branch_prefix}/{issue.key}-{branch_summary}"


def get_jira_key_from_branch_name(branch_name: str) -> str | None:
    if (match := re.search(r'^(\w+/)?(?P<jira_key>[A-Z]{2,}\-[0-9]+)', branch_name)) is not None:
        return match.group('jira_key')
    
    return None

app = typer.Typer()

@app.command()
def detail(issue_key: str):

    issue = jira.issue(issue_key)
    print(issue.fields.project.key)            # 'JRA'
    print(issue.fields.issuetype.name)         # 'New Feature'
    print(issue.fields.reporter.displayName)   # 'Mike Cannon-Brookes [Atlassian]'
    print(f"{issue.fields.timespent=}")
    print(f"{issue.fields.timeestimate=}")
    print(f"{issue.fields.timeoriginalestimate=}")
    print(f"{issue.fields.timetracking.remainingEstimate=}")
    print(f"{issue.fields.timetracking.remainingEstimateSeconds=}")
    print(f"{issue.fields.timetracking.__dict__=}")
    print()
    
@app.command()
def list_mine():
    issues = jira.search_issues(
        f'assignee = currentUser() AND status != Done '
        f'AND {jira_config["common_filters"]["open_sprint"]} '
        f'AND {jira_config["common_filters"]["my_team"]}'
    )
    for issue in issues:
        print(issue.key, issue.fields.summary)

@app.command()
def start():
    issues = jira.search_issues(
        f'status = New '
        f'AND {jira_config["common_filters"]["open_sprint"]} '
        f'AND {jira_config["common_filters"]["my_team"]}'
    )
    for issue in issues:
        print(issue.key, issue.fields.summary)
        breakpoint()
        print()

if __name__ == "__main__":
    app()
