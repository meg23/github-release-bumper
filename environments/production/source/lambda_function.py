import os
import semantic_version

from github import Github
from semantic_version import Version

def lambda_handler(*args, **kwargs):
    try:

        # Fetch environment variables from Lambda config
        repo_name = os.environ["GITHUB_TARGET_REPOSITORY"]
        g = Github(os.environ['GITHUB_API_TOKEN'])

        # Get last release from github repo
        repo = g.get_repo(repo_name)
        last_release = Version.coerce(repo.get_latest_release().tag_name)

        # Bump up to next patch version
        new_release = str(last_release.next_patch())
        new_branch_name = f"release/{new_release}"

        print(f"Bumping version from {last_release} to {new_release}")

        # Create branch, tag, release
        new_branch = repo.create_git_ref(f"refs/heads/{new_branch_name}", repo.get_branch("main").commit.sha)
        new_tag = repo.create_git_tag(str(new_release), "Release tag", new_branch.object.sha, "commit")
        new_ref = repo.create_git_ref(f"refs/tags/{new_release}", new_tag.sha)
        new_release = repo.create_git_release(tag=new_release, name=f"Creating new patch release for {new_release}", message="Automation created this for elevate demo")

    except Exception as e:
        print("An error occurred:", e)

if __name__ == "__main__":
  lambda_handler()
