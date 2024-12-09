#!/bin/bash

# Environment setup
TOKEN=$GITHUB_TOKEN  # GitHub token from environment variables
OWNER="nagesh66"     # GitHub username or organization
REPO="AutoTerra"     # Repository name
BRANCH="main"        # Branch to delete the file from
GITHUB_DIRECTORIES=("sandbox-vending/data")

# Function to fetch disabled projects
fetch_disabled_projects() {
    echo "Fetching disabled projects..."
    gcloud projects list --filter="lifecycleState=DELETE_REQUESTED OR lifecycleState=DELETED" \
        --format="value(projectId)" > disabled_projects.txt
    echo "Disabled projects:"
    cat disabled_projects.txt
}

# Function to find and delete files matching disabled projects
delete_matching_files() {
    echo "Starting file deletion process..."
    
    while IFS= read -r project; do
        echo "Processing project: $project"
        
        for directory in "${GITHUB_DIRECTORIES[@]}"; do
            echo "Checking directory: $directory"
            
            # Search for matching files in the directory
            file_path="$directory/$project.json"
            echo "Looking for file: $file_path"
            
            # Check if the file exists in the GitHub repository
            response=$(curl -s -H "Authorization: token $TOKEN" \
                "https://api.github.com/repos/$OWNER/$REPO/contents/$file_path?ref=$BRANCH")
            
            sha=$(echo "$response" | jq -r '.sha')
            
            if [[ $sha != "null" && -n $sha ]]; then
                echo "Found file: $file_path with SHA: $sha"
                
                # Delete the file
                delete_response=$(curl -s -X DELETE -H "Authorization: token $TOKEN" \
                    -d "{\"message\": \"Delete $file_path\", \"sha\": \"$sha\", \"branch\": \"$BRANCH\"}" \
                    "https://api.github.com/repos/$OWNER/$REPO/contents/$file_path")
                
                echo "Delete response: $delete_response"
            else
                echo "No file found for project: $project in directory: $directory"
            fi
        done
    done < disabled_projects.txt
}

# Main script execution
fetch_disabled_projects
delete_matching_files

echo "File deletion process completed."
