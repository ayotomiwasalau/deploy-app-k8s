# Movie Picture Pipeline

docker build --platform linux/amd64 --build-arg=REACT_APP_MOVIE_API_URL=http://localhost:5000 --tag=mp-frontend:latest .

backend_ecr = "488700172813.dkr.ecr.us-east-1.amazonaws.com/backend"
cluster_name = "cluster"
cluster_version = "1.31"
frontend_ecr = "488700172813.dkr.ecr.us-east-1.amazonaws.com/frontend"
github_action_user_arn = "arn:aws:iam::488700172813:user/github-action-user"
(base) ayotomiwasalau@ayotomiwasalaus-MacBook-Pro terraform % aws configure -list


docker tag mp-frontend:latest 488700172813.dkr.ecr.us-east-1.amazonaws.com/frontend:latest
