# #!/bin/bash

# # Base URLs
# USERS_URL="http://localhost:3000/api/users"

# # Colors for output
# GREEN='\033[0;32m'
# RED='\033[0;31m'
# NC='\033[0m' # No Color

# # Function to print section headers
# print_header() {
#     echo -e "\n${GREEN}=== $1 ===${NC}"
# }

# # Function to make API requests
# make_request() {
#     local method=$1
#     local endpoint=$2
#     local data=$3
    
#     echo "Request: $method $endpoint"
#     if [ -n "$data" ]; then
#         echo "Data: $data"
#     fi
    
#     if [ "$method" = "GET" ]; then
#         curl -s -X $method "$endpoint" | jq .
#     else
#         curl -s -X $method "$endpoint" -H "Content-Type: application/json" -d "$data" | jq .
#     fi
#     echo ""
# }

# # User-related functions
# test_get_all_users() {
#     print_header "Testing GET all users"
#     make_request "GET" "$USERS_URL"
# }

# test_get_user() {
#     print_header "Testing GET user by ID"
#     read -p "Enter user ID: " user_id
#     make_request "GET" "$USERS_URL/$user_id"
# }

# test_create_user() {
#     print_header "Testing POST create user"
#     read -p "Enter first name: " firstName
#     read -p "Enter last name: " lastName
#     read -p "Enter email: " email
    
#     local user_data=$(cat <<EOF
# {
#     "firstName": "$firstName",
#     "lastName": "$lastName",
#     "email": "$email"
# }
# EOF
# )
#     make_request "POST" "$USERS_URL" "$user_data"
# }

# test_update_user() {
#     print_header "Testing PUT update user"
#     read -p "Enter user ID to update: " user_id
#     read -p "Enter new first name (press Enter to keep current): " firstName
#     read -p "Enter new last name (press Enter to keep current): " lastName
#     read -p "Enter new email (press Enter to keep current): " email
    
#     local update_data="{"
#     local has_data=false
    
#     if [ -n "$firstName" ]; then
#         update_data+="\"firstName\": \"$firstName\""
#         has_data=true
#     fi
    
#     if [ -n "$lastName" ]; then
#         if [ "$has_data" = true ]; then
#             update_data+=","
#         fi
#         update_data+="\"lastName\": \"$lastName\""
#         has_data=true
#     fi
    
#     if [ -n "$email" ]; then
#         if [ "$has_data" = true ]; then
#             update_data+=","
#         fi
#         update_data+="\"email\": \"$email\""
#         has_data=true
#     fi
    
#     update_data+="}"
    
#     make_request "PUT" "$USERS_URL/$user_id" "$update_data"
# }

# test_delete_user() {
#     print_header "Testing DELETE user"
#     read -p "Enter user ID to delete: " user_id
#     make_request "DELETE" "$USERS_URL/$user_id"
# }

# # Submenu functions
# show_users_menu() {
#     echo -e "\n${GREEN}Users Menu${NC}"
#     echo "1. Get all users"
#     echo "2. Get user by ID"
#     echo "3. Create new user"
#     echo "4. Update user"
#     echo "5. Delete user"
#     echo "6. Back to main menu"
#     echo -n "Enter your choice (1-6): "
# }

# # Main menu
# show_main_menu() {
#     echo -e "\n${GREEN}API Testing Menu${NC}"
#     echo "1. Users"
#     echo "2. Exit"
#     echo -n "Enter your choice (1-2): "
# }

# # Main loop
# while true; do
#     show_main_menu
#     read choice
#     case $choice in
#         1)
#             while true; do
#                 show_users_menu
#                 read user_choice
#                 case $user_choice in
#                     1) test_get_all_users ;;
#                     2) test_get_user ;;
#                     3) test_create_user ;;
#                     4) test_update_user ;;
#                     5) test_delete_user ;;
#                     6) break ;;
#                     *) echo "Invalid choice. Please try again." ;;
#                 esac
#             done
#             ;;
#         2) echo "Exiting..."; exit 0 ;;
#         *) echo "Invalid choice. Please try again." ;;
#     esac
# done 


#!/bin/bash

BASE_URL="http://localhost:3000/api"
USER_ID=""
POST_ID=""
LIKE_ID=""
FOLLOW_ID=""
HASHTAG_ID=""

main_menu() {
  echo "Backend Intern Assignment Test Script"
  echo "1. User Operations"
  echo "2. Post Operations"
  echo "3. Like Operations"
  echo "4. Follow Operations"
  echo "5. Hashtag Operations"
  echo "6. Special Endpoints"
  echo "7. Exit"
  read -p "Select an option: " choice
  case $choice in
    1) user_menu ;;
    2) post_menu ;;
    3) like_menu ;;
    4) follow_menu ;;
    5) hashtag_menu ;;
    6) special_endpoints_menu ;;
    7) exit 0 ;;
    *) echo "Invalid option"; main_menu ;;
  esac
}

user_menu() {
  echo "User Operations"
  echo "1. Create User"
  echo "2. Get All Users"
  echo "3. Get User by ID"
  echo "4. Update User"
  echo "5. Delete User"
  echo "6. Back"
  read -p "Select an option: " choice
  case $choice in
    1)
      echo "Creating User..."
      response=$(curl -s -X POST "$BASE_URL/users" -H "Content-Type: application/json" -d '{"username":"testuser","email":"test@example.com"}')
      USER_ID=$(echo $response | jq -r '.id')
      echo "Created User: $response"
      ;;
    2)
      echo "Getting All Users..."
      curl -s "$BASE_URL/users" | jq
      ;;
    3)
      echo "Getting User by ID: $USER_ID"
      curl -s "$BASE_URL/users/$USER_ID" | jq
      ;;
    4)
      echo "Updating User..."
      curl -s -X PUT "$BASE_URL/users/$USER_ID" -H "Content-Type: application/json" -d '{"username":"updateduser","email":"updated@example.com"}' | jq
      ;;
    5)
      echo "Deleting User..."
      curl -s -X DELETE "$BASE_URL/users/$USER_ID"
      echo "User deleted"
      ;;
    6) main_menu ;;
    *) echo "Invalid option"; user_menu ;;
  esac
  user_menu
}

post_menu() {
  echo "Post Operations"
  echo "1. Create Post"
  echo "2. Get All Posts"
  echo "3. Get Post by ID"
  echo "4. Update Post"
  echo "5. Delete Post"
  echo "6. Back"
  read -p "Select an option: " choice
  case $choice in
    1)
      echo "Creating Post..."
      response=$(curl -s -X POST "$BASE_URL/posts" -H "Content-Type: application/json" -d "{\"content\":\"Test post\",\"authorId\":\"$USER_ID\",\"hashtags\":[\"test\"]}")
      POST_ID=$(echo $response | jq -r '.id')
      echo "Created Post: $response"
      ;;
    2)
      echo "Getting All Posts..."
      curl -s "$BASE_URL/posts" | jq
      ;;
    3)
      echo "Getting Post by ID: $POST_ID"
      curl -s "$BASE_URL/posts/$POST_ID" | jq
      ;;
    4)
      echo "Updating Post..."
      curl -s -X PUT "$BASE_URL/posts/$POST_ID" -H "Content-Type: application/json" -d "{\"content\":\"Updated post\",\"authorId\":\"$USER_ID\",\"hashtags\":[\"updated\"]}" | jq
      ;;
    5)
      echo "Deleting Post..."
      curl -s -X DELETE "$BASE_URL/posts/$POST_ID"
      echo "Post deleted"
      ;;
    6) main_menu ;;
    *) echo "Invalid option"; post_menu ;;
  esac
  post_menu
}

like_menu() {
  echo "Like Operations"
  echo "1. Create Like"
  echo "2. Get All Likes"
  echo "3. Get Like by ID"
  echo "4. Delete Like"
  echo "5. Back"
  read -p "Select an option: " choice
  case $choice in
    1)
      echo "Creating Like..."
      response=$(curl -s -X POST "$BASE_URL/likes" -H "Content-Type: application/json" -d "{\"userId\":\"$USER_ID\",\"postId\":\"$POST_ID\"}")
      LIKE_ID=$(echo $response | jq -r '.id')
      echo "Created Like: $response"
      ;;
    2)
      echo "Getting All Likes..."
      curl -s "$BASE_URL/likes" | jq
      ;;
    3)
      echo "Getting Like by ID: $LIKE_ID"
      curl -s "$BASE_URL/likes/$LIKE_ID" | jq
      ;;
    4)
      echo "Deleting Like..."
      curl -s -X DELETE "$BASE_URL/likes/$LIKE_ID"
      echo "Like deleted"
      ;;
    5) main_menu ;;
    *) echo "Invalid option"; like_menu ;;
  esac
  like_menu
}

follow_menu() {
  echo "Follow Operations"
  echo "1. Create Follow"
  echo "2. Get All Follows"
  echo "3. Get Follow by ID"
  echo "4. Delete Follow"
  echo "5. Back"
  read -p "Select an option: " choice
  case $choice in
    1)
      echo "Creating Follow..."
      response=$(curl -s -X POST "$BASE_URL/follows" -H "Content-Type: application/json" -d "{\"followerId\":\"$USER_ID\",\"followingId\":\"$USER_ID\"}")
      FOLLOW_ID=$(echo $response | jq -r '.id')
      echo "Created Follow: $response"
      ;;
    2)
      echo "Getting All Follows..."
      curl -s "$BASE_URL/follows" | jq
      ;;
    3)
      echo "Getting Follow by ID: $FOLLOW_ID"
      curl -s "$BASE_URL/follows/$FOLLOW_ID" | jq
      ;;
    4)
      echo "Deleting Follow..."
      curl -s -X DELETE "$BASE_URL/follows/$FOLLOW_ID"
      echo "Follow deleted"
      ;;
    5) main_menu ;;
    *) echo "Invalid option"; follow_menu ;;
  esac
  follow_menu
}

hashtag_menu() {
  echo "Hashtag Operations"
  echo "1. Create Hashtag"
  echo "2. Get All Hashtags"
  echo "3. Get Hashtag by ID"
  echo "4. Delete Hashtag"
  echo "5. Back"
  read -p "Select an option: " choice
  case $choice in
    1)
      echo "Creating Hashtag..."
      response=$(curl -s -X POST "$BASE_URL/hashtags" -H "Content-Type: application/json" -d '{"tag":"test"}')
      HASHTAG_ID=$(echo $response | jq -r '.id')
      echo "Created Hashtag: $response"
      ;;
    2)
      echo "Getting All Hashtags..."
      curl -s "$BASE_URL/hashtags" | jq
      ;;
    3)
      echo "Getting Hashtag by ID: $HASHTAG_ID"
      curl -s "$BASE_URL/hashtags/$HASHTAG_ID" | jq
      ;;
    4)
      echo "Deleting Hashtag..."
      curl -s -X DELETE "$BASE_URL/hashtags/$HASHTAG_ID"
      echo "Hashtag deleted"
      ;;
    5) main_menu ;;
    *) echo "Invalid option"; hashtag_menu ;;
  esac
  hashtag_menu
}

special_endpoints_menu() {
  echo "Special Endpoints"
  echo "1. Get Feed"
  echo "2. Get Posts by Hashtag"
  echo "3. Get User Followers"
  echo "4. Get User Activity"
  echo "5. Back"
  read -p "Select an option: " choice
  case $choice in
    1)
      echo "Getting Feed..."
      curl -s "$BASE_URL/posts/feed?userId=$USER_ID&limit=10&offset=0" | jq
      ;;
    2)
      echo "Getting Posts by Hashtag: test"
      curl -s "$BASE_URL/posts/hashtag/test?limit=10&offset=0" | jq
      ;;
    3)
      echo "Getting User Followers..."
      curl -s "$BASE_URL/users/$USER_ID/followers?limit=10&offset=0" | jq
      ;;
    4)
      echo "Getting User Activity..."
      curl -s "$BASE_URL/users/$USER_ID/activity?limit=10&offset=0" | jq
      ;;
    5) main_menu ;;
    *) echo "Invalid option"; special_endpoints_menu ;;
  esac
  special_endpoints_menu
}

main_menu