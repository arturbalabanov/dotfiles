# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "typer",
# ]
# ///

import subprocess
import json
from typing import Literal
import pathlib
import sys

import typer

app = typer.Typer()


def get_main_screen_resoltution() -> tuple[int, int]:
    # NOTE: This is using the MacOS's main screen, i.e. the one with the menu bar,
    #       maybe I should use the currently active screen instead?

    if sys.platform != "darwin":
        raise NotImplementedError("This function is only implemented for MacOS")

    screen_resolution = subprocess.check_output(
        ["system_profiler", "SPDisplaysDataType", "-json"]
    ).decode("utf-8")

    screen_data = json.loads(screen_resolution)
    displays = screen_data["SPDisplaysDataType"]

    for display in displays:
        for ndrv in display.get("spdisplays_ndrvs", []):
            if ndrv.get("spdisplays_main") == "spdisplays_yes":
                pixels = ndrv.get("_spdisplays_pixels", "")
                width, height = map(int, pixels.split(" x "))

                return width, height

    raise RuntimeError("Main screen resolution not found")


Heroes3Editions = Literal["sod", "hota"]


sod_launcher_path = pathlib.Path.home() / "Applications" / "Heroes 3 - Shadow of Death (SoD).app"
hota_launcher_path = pathlib.Path.home() / "Applications" / "Heroes 3 - Horn of the Abyss (HotA).app"

@app.command()
def main(
    edition: Heroes3Editions = typer.Argument(help="Heroes 3 edition to launch"),
    launcher: bool = typer.Option(False, help="Launch the game launcher"),
):
    if launcher:
        if edition == "sod":
            subprocess.call(["open", str(sod_launcher_path)])
        elif edition == "hota":
            subprocess.call(["open", str(hota_launcher_path)])
        else:
            raise ValueError(f"Unknown edition: {edition}")

        return
        
    x, y = get_main_screen_resoltution()
    aspect_ratio = x / y


if __name__ == "__main__":
    app()
