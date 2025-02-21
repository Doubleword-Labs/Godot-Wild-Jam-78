import os
import subprocess
import shutil
import argparse
from typing import Sequence
from zipfile import ZipFile

#================================================================
# Settings
#================================================================

PROJECT_NAME = "JasonDrawn"
PROJECT_PATH = "project.godot"

GODOT_PATH = "godot"
BIN_DIR = "bin"

ITCHIO_USER="nathansdunn"
ITCHIO_PROJECT="jason-drawn"

#================================================================
# Helper functions
#================================================================

class ProgramArgs(argparse.Namespace):
    godot: str
    project_name: str
    project_path: str
    bin_dir: str
    itchio_user: str
    itchio_project: str
    no_build: bool
    upload: bool
    windows: bool | None
    macos: bool | None
    linux: bool | None
    web: bool | None = False
    debug: bool | None = False


def cmd(command: str):
    print(f"Running: {command}")
    subprocess.run(command, shell=True, check=True)

def zip_directory(dir_path: str, zip_name: str):
    if os.path.isdir(dir_path):
        pass
    elif os.path.isfile(dir_path):
        dir_path = os.path.dirname(dir_path)
    else:
        print(f"{dir_path} is not valid")
        exit(1)

    print(f"Zipping {dir_path} to {zip_name}.zip")
    zip_path = f"{zip_name}.zip"
    if os.path.exists(zip_path):
        os.remove(zip_path)

    with ZipFile(zip_path, "w") as zipf:
        for root, _, files in os.walk(dir_path):
            for file in files:
                zipf.write(
                    os.path.join(root, file),
                    os.path.relpath(os.path.join(root, file), dir_path),
                )

def get_platforms(args: ProgramArgs) -> dict[str, bool]:
    if args.web or args.windows or args.macos or args.linux:
        return {
            "windows": args.windows is True,
            "macos": args.macos is True,
            "linux": args.linux is True,
            "web": args.web is True
        }

    return {
        "windows": True,
        "macos": True,
        "linux": True,
        "web": True
    }

PLATFORM_MAP = {
    "windows": "Windows Desktop",
    "macos": "macOS",
    "linux": "Linux",
    "web": "Web"
}

def export_platform(platform: str, output_path: str, dest_zip_name: str, args: ProgramArgs):
    print(f"Exporting for {PLATFORM_MAP[platform]}...")

    source_dir = f"{args.bin_dir}/{platform}"

    # Clean up old builds
    # if os.path.exists(source_dir):
    #     shutil.rmtree(source_dir)

    os.makedirs(source_dir, exist_ok=True)

    export_config_arg = "--export-debug" if args.debug else "--export-release"
    cmd(f'{args.godot} --headless {export_config_arg} "{PLATFORM_MAP[platform]}" {output_path}')

    zip_directory(source_dir, dest_zip_name)


#================================================================
# Main script logic
#================================================================

def main(args: ProgramArgs):
    # Assign variables from CLI arguments
    godot = args.godot
    project_name = args.project_name
    project_path = args.project_path
    bin_dir = args.bin_dir
    export_path_linux = f"{bin_dir}/linux/{project_name}.x86_64"
    export_path_mac = f"{bin_dir}/macos/{project_name}.app"
    export_path_windows = f"{bin_dir}/windows/{project_name}.exe"
    export_path_web = f"{bin_dir}/web/index.html"
    itchio_user = args.itchio_user
    itchio_project = args.itchio_project
    upload = args.upload or args.no_build
    no_build = args.no_build

    platforms = get_platforms(args)

    if not no_build:
        if platforms["windows"]:
            export_platform("windows", export_path_windows, f"{bin_dir}/{project_name}[WIN]", args)

        if platforms["macos"]:
            export_platform("macos", export_path_mac, f"{bin_dir}/{project_name}[MACOS]", args)

        if platforms["linux"]:
            export_platform("linux", export_path_linux, f"{bin_dir}/{project_name}[LINUX]", args)

        if platforms["web"]:
            export_platform("web", export_path_web, f"{bin_dir}/{project_name}[WEB]", args)

    # Upload using butler if upload flag is set
    if upload:
        print("Uploading to itch using butler...")

        if platforms["windows"]:
            cmd(f'butler push "{bin_dir}/{project_name}[WIN].zip" {itchio_user}/{itchio_project}:win')

        if platforms["macos"]:
            cmd(f'butler push "{bin_dir}/{project_name}[MACOS].zip" {itchio_user}/{itchio_project}:macos')

        if platforms["linux"]:
            cmd(f'butler push "{bin_dir}/{project_name}[LINUX].zip" {itchio_user}/{itchio_project}:linux')

        if platforms["web"]:
            cmd(f'butler push "{bin_dir}/{project_name}[WEB].zip" {itchio_user}/{itchio_project}:web')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Build and export Godot project for multiple platforms.')
    parser.add_argument('--godot', type=str, default=GODOT_PATH, help='Path to the Godot executable')
    parser.add_argument('--project-name', type=str, default=PROJECT_NAME, help='Project name')
    parser.add_argument('--project-path', type=str, default=PROJECT_PATH, help='Path to the Godot project file')
    parser.add_argument('--bin-dir', type=str, default=BIN_DIR, help='Directory to store the build files')
    parser.add_argument('--itchio-user', type=str, default=ITCHIO_USER, help='Itch.io username')
    parser.add_argument('--itchio-project', type=str, default=ITCHIO_PROJECT, help='Itch.io project name')
    parser.add_argument('--upload', action='store_true', help='Upload the build files to itch.io using butler')
    parser.add_argument('--upload-only', action='store_true', dest="no_build", help='Upload the build files to itch.io using butler without building')
    parser.add_argument('--debug', action='store_true', help='Enable debug mode', default=False)

    # Arguments for specifying the platform to build
    parser.add_argument('--windows', action='store_true', help='Build for Windows', default=None)
    parser.add_argument('--macos', action='store_true', help='Build for MacOS', default=None)
    parser.add_argument('--linux', action='store_true', help='Build for Linux', default=None)
    parser.add_argument('--web', action='store_true', help='Build for Web', default=None)

    args = parser.parse_args(namespace=ProgramArgs())
    main(args)
