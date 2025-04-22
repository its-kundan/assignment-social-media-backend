#!/bin/bash

# Base URLs
BASE_URL="http://localhost:3000"
API_PREFIX="/api"
USERS_URL="${BASE_URL}${API_PREFIX}/users"
POSTS_URL="${BASE_URL}${API_PREFIX}/posts"
LIKES_URL="${BASE_URL}${API_PREFIX}/likes"
FOLLOWS_URL="${BASE_URL}${API_PREFIX}/follows"
HASHTAGS_URL="${BASE_URL}${API_PREFIX}/hashtags"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${GREEN}=== $1 ===${NC}"
}

# Function to print test result
print_result() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✓ $message${NC}"
    else
        echo -e "${RED}✗ $message (Status: $status)${NC}"
    fi
}

# Function to make API requests
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4

    echo "Request: $method $endpoint"
    if [ -n "$data" ]; then
        echo "Data: $data"
    fi

    local response
    local status
    local body
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$endpoint") || { echo "curl failed"; return 1; }
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$endpoint" -H "Content-Type: application/json" -d "$data") || { echo "curl failed"; return 1; }
    fi
    status=$(echo "$response" | tail -n 1) || { echo "tail failed"; return 1; }
    body=$(echo "$response" | sed -e '$d') || { echo "sed failed"; return 1; }

    echo "$body" | jq .
    echo ""

    if [ "$status" -eq "$expected_status" ]; then
        print_result 0 "$method $endpoint"
    else
        print_result "$status" "$method $endpoint"
    fi

    echo "$body"
}

# Generic CRUD test function
test_crud() {
    local entity=$1
    local url=$2
    local create_data=$3
    local update_data=$4
    local entity_name=$(echo "$entity" | tr '[:lower:]' '[:upper:]')

    print_header "Testing $entity_name CRUD Operations"

    # Create
    local create_response
    local create_status
    local id
    create_response=$(make_request "POST" "$url" "$create_data" 201) || { echo "make_request failed"; return 1; }
    create_status=$(echo "$create_response" | jq -r '.id' 2>/dev/null) || { echo "jq failed"; return 1; }
    id=$create_status

    if [ -n "$id" ]; then
        echo "Created $entity with ID: $id"

        # Get by ID
        make_request "GET" "$url/$id" "" 200

        # Get all
        make_request "GET" "$url" "" 200

        # Update
        make_request "PUT" "$url/$id" "$update_data" 200

        # Delete
        make_request "DELETE" "$url/$id" "" 204
    else
        echo "Skipping further tests due to creation failure"
    fi
}

# Entity-specific submenu functions
show_users_submenu() {
    while true; do
        echo -e "\n${GREEN}Users Submenu${NC}"
        echo "1. Get all users"
        echo "2. Get user by ID"
        echo "3. Create new user"
        echo "4. Update user"
        echo "5. Delete user"
        echo "6. Back to main menu"
        read -r -p "Enter your choice (1-6): " choice
        case $choice in
            1) make_request "GET" "$USERS_URL" "" 200 ;;
            2) read -r -p "Enter user ID: " id
               make_request "GET" "$USERS_URL/$id" "" 200 ;;
            3) read -r -p "Enter first name: " firstName
               read -r -p "Enter last name: " lastName
               read -r -p "Enter email: " email
               local user_data="{\"firstName\":\"$firstName\",\"lastName\":\"$lastName\",\"email\":\"$email\"}"
               make_request "POST" "$USERS_URL" "$user_data" 201 ;;
            4) read -r -p "Enter user ID to update: " id
               read -r -p "Enter new first name (optional): " firstName
               read -r -p "Enter new last name (optional): " lastName
               read -r -p "Enter new email (optional): " email
               local update_data="{"
               local has_data=false
               [ -n "$firstName" ] && { update_data+="\"firstName\":\"$firstName\""; has_data=true; }
               [ -n "$lastName" ] && { [ "$has_data" = true ] && update_data+=","; update_data+="\"lastName\":\"$lastName\""; has_data=true; }
               [ -n "$email" ] && { [ "$has_data" = true ] && update_data+=","; update_data+="\"email\":\"$email\""; }
               update_data+="}"
               make_request "PUT" "$USERS_URL/$id" "$update_data" 200 ;;
            5) read -r -p "Enter user ID to delete: " id
               make_request "DELETE" "$USERS_URL/$id" "" 204 ;;
            6) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

show_posts_submenu() {
    while true; do
        echo -e "\n${GREEN}Posts Submenu${NC}"
        echo "1. Get all posts"
        echo "2. Get post by ID"
        echo "3. Create new post"
        echo "4. Update post"
        echo "5. Delete post"
        echo "6. Back to main menu"
        read -r -p "Enter your choice (1-6): " choice
        case $choice in
            1) make_request "GET" "$POSTS_URL" "" 200 ;;
            2) read -r -p "Enter post ID: " id
               make_request "GET" "$POSTS_URL/$id" "" 200 ;;
            3) read -r -p "Enter post content: " content
               read -r -p "Enter author ID: " authorId
               read -r -p "Enter hashtag tags (comma-separated, optional): " hashtagTags
               local tags_array
               if [ -n "$hashtagTags" ]; then
                   local tags_temp
                   local tags_comma
                   tags_temp=$(echo "$hashtagTags" | awk -F',' '{for(i=1;i<=NF;i++) print "\"" $i "\""}') || { echo "awk failed"; return 1; }
                   tags_comma=$(echo "$tags_temp" | tr '\n' ',' | sed 's/,$//') || { echo "tr or sed failed"; return 1; }
                   tags_array="[${tags_comma}]"
               else
                   tags_array="[]"
               fi
               local post_data="{\"content\":\"$content\",\"authorId\":$authorId,\"hashtagTags\":$tags_array}"
               make_request "POST" "$POSTS_URL" "$post_data" 201 ;;
            4) read -r -p "Enter post ID to update: " id
               read -r -p "Enter new content (optional): " content
               local update_data="{\"content\":\"$content\"}"
               make_request "PUT" "$POSTS_URL/$id" "$update_data" 200 ;;
            5) read -r -p "Enter post ID to delete: " id
               make_request "DELETE" "$POSTS_URL/$id" "" 204 ;;
            6) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

show_likes_submenu() {
    while true; do
        echo -e "\n${GREEN}Likes Submenu${NC}"
        echo "1. Get all likes"
        echo "2. Get like by ID"
        echo "3. Create new like"
        echo "4. Delete like"
        echo "5. Back to main menu"
        read -r -p "Enter your choice (1-5): " choice
        case $choice in
            1) make_request "GET" "$LIKES_URL" "" 200 ;;
            2) read -r -p "Enter like ID: " id
               make_request "GET" "$LIKES_URL/$id" "" 200 ;;
            3) read -r -p "Enter user ID: " userId
               read -r -p "Enter post ID: " postId
               local like_data="{\"userId\":$userId,\"postId\":$postId}"
               make_request "POST" "$LIKES_URL" "$like_data" 201 ;;
            4) read -r -p "Enter like ID to delete: " id
               make_request "DELETE" "$LIKES_URL/$id" "" 204 ;;
            5) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

show_follows_submenu() {
    while true; do
        echo -e "\n${GREEN}Follows Submenu${NC}"
        echo "1. Get all follows"
        echo "2. Get follow by ID"
        echo "3. Create new follow"
        echo "4. Delete follow"
        echo "5. Back to main menu"
        read -r -p "Enter your choice (1-5): " choice
        case $choice in
            1) make_request "GET" "$FOLLOWS_URL" "" 200 ;;
            2) read -r -p "Enter follow ID: " id
               make_request "GET" "$FOLLOWS_URL/$id" "" 200 ;;
            3) read -r -p "Enter follower ID: " followerId
               read -r -p "Enter followed ID: " followedId
               local follow_data="{\"followerId\":$followerId,\"followedId\":$followedId}"
               make_request "POST" "$FOLLOWS_URL" "$follow_data" 201 ;;
            4) read -r -p "Enter follow ID to delete: " id
               make_request "DELETE" "$FOLLOWS_URL/$id" "" 204 ;;
            5) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

show_hashtags_submenu() {
    while true; do
        echo -e "\n${GREEN}Hashtags Submenu${NC}"
        echo "1. Get all hashtags"
        echo "2. Get hashtag by ID"
        echo "3. Create new hashtag"
        echo "4. Update hashtag"
        echo "5. Delete hashtag"
        echo "6. Back to main menu"
        read -r -p "Enter your choice (1-6): " choice
        case $choice in
            1) make_request "GET" "$HASHTAGS_URL" "" 200 ;;
            2) read -r -p "Enter hashtag ID: " id
               make_request "GET" "$HASHTAGS_URL/$id" "" 200 ;;
            3) read -r -p "Enter hashtag tag: " tag
               local hashtag_data="{\"tag\":\"$tag\"}"
               make_request "POST" "$HASHTAGS_URL" "$hashtag_data" 201 ;;
            4) read -r -p "Enter hashtag ID to update: " id
               read -r -p "Enter new tag: " tag
               local update_data="{\"tag\":\"$tag\"}"
               make_request "PUT" "$HASHTAGS_URL/$id" "$update_data" 200 ;;
            5) read -r -p "Enter hashtag ID to delete: " id
               make_request "DELETE" "$HASHTAGS_URL/$id" "" 204 ;;
            6) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

show_special_endpoints_submenu() {
    while true; do
        echo -e "\n${GREEN}Special Endpoints Submenu${NC}"
        echo "1. Get user feed"
        echo "2. Get posts by hashtag"
        echo "3. Get user followers"
        echo "4. Get user activity"
        echo "5. Back to main menu"
        read -r -p "Enter your choice (1-5): " choice
        case $choice in
            1) read -r -p "Enter user ID: " userId
               read -r -p "Enter limit (default 10): " limit
               read -r -p "Enter offset (default 0): " offset
               [ -z "$limit" ] && limit=10
               [ -z "$offset" ] && offset=0
               make_request "GET" "$POSTS_URL/feed?userId=$userId&limit=$limit&offset=$offset" "" 200 ;;
            2) read -r -p "Enter hashtag: " tag
               read -r -p "Enter limit (default 10): " limit
               read -r -p "Enter offset (default 0): " offset
               [ -z "$limit" ] && limit=10
               [ -z "$offset" ] && offset=0
               make_request "GET" "$POSTS_URL/hashtag/$tag?limit=$limit&offset=$offset" "" 200 ;;
            3) read -r -p "Enter user ID: " userId
               read -r -p "Enter limit (default 10): " limit
               read -r -p "Enter offset (default 0): " offset
               [ -z "$limit" ] && limit=10
               [ -z "$offset" ] && offset=0
               make_request "GET" "$FOLLOWS_URL/users/$userId/followers?limit=$limit&offset=$offset" "" 200 ;;
            4) read -r -p "Enter user ID: " userId
               read -r -p "Enter limit (default 10): " limit
               read -r -p "Enter offset (default 0): " offset
               read -r -p "Enter activity type (post/like/follow, optional): " activityType
               read -r -p "Enter start date (YYYY-MM-DD, optional): " startDate
               read -r -p "Enter end date (YYYY-MM-DD, optional): " endDate
               [ -z "$limit" ] && limit=10
               [ -z "$offset" ] && offset=0
               local query="limit=$limit&offset=$offset"
               [ -n "$activityType" ] && query="$query&type=$activityType"
               [ -n "$startDate" ] && query="$query&startDate=$startDate"
               [ -n "$endDate" ] && query="$query&endDate=$endDate"
               make_request "GET" "$USERS_URL/$userId/activity?$query" "" 200 ;;
            5) break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

# Main menu
while true; do
    echo -e "\n${GREEN}API Testing Menu${NC}"
    echo "1. Users"
    echo "2. Posts"
    echo "3. Likes"
    echo "4. Follows"
    echo "5. Hashtags"
    echo "6. Special Endpoints"
    echo "7. Run Automated CRUD Tests"
    echo "8. Exit"
    read -r -p "Enter your choice (1-8): " choice
    case $choice in
        1) show_users_submenu ;;
        2) show_posts_submenu ;;
        3) show_likes_submenu ;;
        4) show_follows_submenu ;;
        5) show_hashtags_submenu ;;
        6) show_special_endpoints_submenu ;;
        7) echo -e "\n${GREEN}Running Automated CRUD Tests${NC}"
           test_crud "users" "$USERS_URL" '{"firstName":"John","lastName":"Doe","email":"john.doe@example.com"}' '{"firstName":"Jane"}'
           test_crud "posts" "$POSTS_URL" '{"content":"Hello World","authorId":1,"hashtagTags":["test"]}' '{"content":"Updated content"}'
           test_crud "likes" "$LIKES_URL" '{"userId":1,"postId":1}' '{}'
           test_crud "follows" "$FOLLOWS_URL" '{"followerId":1,"followedId":2}' '{}'
           test_crud "hashtags" "$HASHTAGS_URL" '{"tag":"test"}' '{"tag":"updated"}'
           echo -e "\n${GREEN}Testing Special Endpoints${NC}"
           make_request "GET" "$POSTS_URL/feed?userId=1&limit=10&offset=0" "" 200
           make_request "GET" "$POSTS_URL/hashtag/test?limit=10&offset=0" "" 200
           make_request "GET" "$FOLLOWS_URL/users/1/followers?limit=10&offset=0" "" 200
           make_request "GET" "$USERS_URL/1/activity?limit=10&offset=0" "" 200 ;;
        8) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done