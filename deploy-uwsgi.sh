#!/usr/bin/env bash

IDENTITY_FILE="$HOME/.ssh/fastcampus-8th.pem"
USER="ubuntu"
HOST="ec2-52-79-236-142.ap-northeast-2.compute.amazonaws.com"
PROJECT_DIR="$HOME/projects/deploy/ec2-deploy"
SERVER_DIR="/home/ubuntu/project"

# ssh로 서버에 접속하는 명령어
CMD_CONNECT="ssh -i ${IDENTITY_FILE} ${USER}@${HOST}"

echo "Start deploy"

# 서버에서 실행중이던 runserver 프로세스들을 모두종료
${CMD_CONNECT}  " sudo fuser -k 8000/tcp"
${CMD_CONNECT}  "sudo lsof -t -i tcp:8000 | xargs kill -9"
echo "- Kill runserver processes"

# 서버의 파일을 지움
${CMD_CONNECT} rm -rf ${SERVER_DIR}
echo "- Delete server files"

# 서버에 프로젝트 파일을 다시 업로드
scp -q -i ${IDENTITY_FILE} -r ${PROJECT_DIR} ${USER}@${HOST}:${SERVER_DIR}
echo "- Upload files"


# 서버 접속 후 SERVER_DIR로 이동, pipenv --venv로 가상환경의 경로 가져오기
VENV_PATH=$(${CMD_CONNECT} "cd ${SERVER_DIR} && pipenv --venv")
# 가상환경의 경로에 /bin/python을 붙여 서버에서 사용하는 python의 경로 만들기
UWSGI_PATH="${VENV_PATH}/bin/uwsgi"
echo " -Get Uwsgi path ${UWSGI_PATH}"

# uwsgi로 runserver시킴
RUNSERVER_CMD="nohup ${UWSGI_PATH} --ini .config/uwsgi_server_http.ini"

# 서버 접속 후, 프로젝트의 폴더까지 이동한 후 uwsgi명령어 실행
${CMD_CONNECT} "cd ${SERVER_DIR} && ${RUNSERVER_CMD}"
echo "- Excute runserver"
echo "Deploy complete"