#!/bin/bash

#1. 배포된 파일이 위치한 디렉토리(appspec.yml의 destination과 일치)
ROOT_PATH="/home/ec2-user/app/step2/zip"
JAR_DIR="/home/ec2-user/app/step2/zip/build/libs"

cd $ROOT_PATH

echo ">현재 구동 중인 애플리케이션 pid 확인"
CURRENT_PID=$(pgrep -f simple-springboot3-webservice) # 프로젝트 이름 혹은 jar 이름 일부

if [ -z "$CURRENT_PID" ]; then
  echo "> 현재 구동 중인 애플리케이션이 없으므로 종료하지 않습니다."
else
  echo "> kill -15 $CURRENT_PID"
  kill -15 $CURRENT_PID
  sleep 5
fi

echo "> 새 애플리케이션 배포"

#jar 파일 찾기 (plain jar 제외)
JAR_NAME=$(ls $JAR_DIR/*.jar | grep -v 'plain')

echo "> JAR Name: $JAR_NAME"

echo "> $JAR_NAME 에 실행권한 추가"
chmod +x $JAR_NAME

echo "> $JAR_NAME 실행"

#nohup으로 백그라운드 실행 & 로그남기기
nohup java -jar \
  -Xms512m -XmX512m \
  -Dspring.config.location=file:/home/ec2-user/app/application-oauth.properties,file:/home/ec2-user/app/application-real-db.properties \
  -Dspring.profiles.active=oauth,real-db \
  $JAR_NAME > $ROOT_PATH/nohup.out 2>&1 &