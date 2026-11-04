1. 프로젝트 소개 및 목표
이 프로젝트는 Linux CLI, Docker 및 Git/GitHub를 사용해 재현 가능한 개발 워크스테이션을 구축하는 실습이다. Linux에서 파일과 디렉터리를 다루고 권한을 변경한 뒤, Docker 이미지/컨테이너를 운영했다. NGINX를 기반으로 직접 Dockerfile과 HTML 페이지를 작성하여 커스텀 웹 서버 이미지를 만들고, 포트 매핑·바인드 마운트·볼륨 영속성을 검증했다. 마지막으로 로컬 Git 저장소를 GitHub 원격 저장소와 연결했다.

Git과 GitHub의 차이: Git은 로컬에서 파일 변경 이력을 저장하는 버전 관리 도구이며, GitHub는 Git 저장소를 인터넷으로 공유하고 협업하는 플랫폼이다.
2. 실행 환경
구성요소	실습 환경 또는 버전
호스트 운영체제	Windows (정확한 버전은 winver로 확인 후 작성)
Linux 환경	WSL 2 / Ubuntu (배포판 버전은 cat /etc/os-release 확인 후 작성)
Shell / 터미널	Bash / VS Code 통합 WSL 터미널
Docker 런타임	Docker Desktop + WSL Integration
Docker CLI	29.9.2 (평가 로그에 나타난 버전 — 실제 현재값 재확인)
Git	2.53.0 (실습 화면에서 확인된 버전)
IDE	Visual Studio Code


환경 점검 명령:
uname -s
cat /etc/os-release
echo "$SHELL"
docker --version
docker info
git --version
검증 기준: uname -s에서 Linux, docker info에서 Client와 Server 정보가 모두 출력되면 Linux 셸과 Docker 엔진의 연결을 확인할 수 있다. docker --version만 성공한다고 엔진까지 실행 중이라는 뜻은 아니다.
- 실행 기록: [Docker 기본 점검 로그](logs/docker-practice.txt)
- 명령어와 출력이 포함된 캡처: [evidence 폴더](evidence/)
3. 프로젝트 구조 및 디렉터리 역할
dev-workstation/
├── README.md                # 실습 목적, 수행 과정, 검증 방법, 문제 해결 기록
├── Dockerfile               # NGINX 기반 커스텀 이미지 제작 방법
├── app/
│   └── index.html           # 빌드 시 이미지에 복사되는 웹 페이지
├── bind-site/
│   └── index.html           # 바인드 마운트 반영 테스트용 웹 페이지
├── practice/                # Linux 파일 조작 및 권한 변경 실습
├── logs/                    # 명령어와 실행 결과 텍스트 로그
└── evidence/                # 터미널 및 브라우저 스크린샷
app/은 이미지에 포함되는 정적 콘텐츠, bind-site/는 컨테이너 실행 중 호스트에서 수정하는 콘텐츠다. logs/에는 CLI 명령어 및 출력, evidence/에는 터미널 화면과 브라우저 주소창을 포함한 캡처를 저장한다. 로컬 PC의 계정명이나 홈 경로가 달라도 ~/dev-workstation 또는 저장소의 루트 경로를 기준으로 실행할 수 있게 구성한다.
4. 수행 체크리스트
- [x] WSL Ubuntu 터미널에서 Linux 기본 명령어 실습
- [x] 파일/디렉터리 권한 변경 및 로그 기록
- [x] Docker 버전 및 엔진 점검
- [x] hello-world 실행 및 docker ps -a / docker logs 확인
- [x] Ubuntu 컨테이너 실행 및 내부 명령어 실습
- [x] Dockerfile로 커스텀 NGINX 이미지 빌드
- [x] 포트 8080, 8081에서 웹 서버 접속 실습
- [x] 바인드 마운트 변경 전후 확인
- [x] Docker 볼륨의 컨테이너 삭제 전후 데이터 유지 검증
- [x] 로컬 Git 저장소의 main 브랜치를 GitHub에 Push
- [ ] 아래 README의 실제 파일 링크, 캡처, 미확인 출력 최종 검토 완료
체크한 실습의 실행 흔적은 logs/에서 확인할 수 있다. 검증된 스크린샷 파일이 있다면 아래 관련 섹션에 실제 파일명으로 링크를 추가한다.
5. Linux CLI 실습 / 경로와 권한
5.1 파일 조작
pwd                  # 현재 경로 확인
ls -la               # 숨김 파일과 권한 포함 확인
mkdir -p practice     # 폴더 생성
cd practice           # 상대 경로 이동
touch hello.txt       # 빈 파일 생성
echo "Hello Linux" > hello.txt
cat hello.txt         # 파일 내용 확인
cp hello.txt copy.txt # 복사
mv copy.txt renamed.txt  # 이동/이름 변경
rm renamed.txt        # 삭제
cd ..                 # 상위 폴더 이동
절대 경로 /home/<사용자명>/dev-workstation/practice는 루트(/)부터 시작하고, 상대 경로 ./practice는 현재 디렉터리를 기준으로 한다. ..는 상위 디렉터리를 가리킨다.
- [터미널 기본 명령어 실행 로그](logs/linux-practice.txt)
5.2 권한 변경과 숫자 표기
touch practice/permission.txt
chmod 600 practice/permission.txt
ls -l practice/permission.txt
chmod 644 practice/permission.txt
ls -l practice/permission.txt

mkdir -p practice/permission-dir
chmod 700 practice/permission-dir
ls -ld practice/permission-dir
chmod 755 practice/permission-dir
ls -ld practice/permission-dir
실제 비교 로그에서 관찰한 형태:
파일 변경 전: -rw------- (600)
파일 변경 후: -rw-r--r-- (644)
폴더 변경 전: drwx------ (700)
폴더 변경 후: drwxr-xr-x (755)
r(읽기)=4, w(쓰기)=2, x(실행)=1이다. 숫자 세 자리는 차례로 소유자 / 그룹 / 기타 사용자의 권한 합을 뜻한다. 예를 들어 755 = 7(rwx) 5(r-x) 5(r-x), **644 = 6(rw-) 4(r--) 4(r--)**이다. 디렉터리에서 x는 해당 디렉터리를 통과해 내부 항목에 접근하는 권한으로도 쓰인다. 일반 HTML 같은 데이터 파일은 보통 실행 권한을 부여할 필요가 없다.
- [파일·폴더 권한 변경 로그](logs/permission-practice.txt)
6. Docker 기본 운영과 이미지 / 컨테이너 차이
docker --version
docker info
docker pull hello-world
docker pull ubuntu:24.04
docker pull nginx:alpine
docker images
docker run hello-world
docker ps
docker ps -a
# 실행한 hello-world 컨테이너 이름 또는 ID를 확인한 뒤:
docker logs <hello-world-컨테이너이름-또는-ID>
docker stats --no-stream
hello-world가 Hello from Docker!를 출력하면 이미지 다운로드부터 컨테이너 실행까지의 경로를 검증할 수 있다. 메시지 출력이 끝나면 컨테이너가 종료되므로 docker ps에는 보이지 않아도 docker ps -a에서는 Exited (0)으로 나타날 수 있다. docker logs는 존재하는 컨테이너의 이름/ID로 확인해야 한다. docker stats --no-stream은 실행 중 컨테이너의 CPU/메모리 사용량을 한 번 표시한다.

이미지와 컨테이너의 차이: 이미지는 실행에 필요한 파일과 설정을 포함한 불변에 가까운 템플릿이고, 컨테이너는 그 이미지로 생성되어 동작하는 실행 인스턴스다. 같은 이미지로 여러 컨테이너를 실행할 수 있으며, 각 컨테이너는 별도 파일 쓰기 계층과 프로세스 환경을 갖는다.

Ubuntu 컨테이너 재현 실습:
docker run -it --name ubuntu-demo ubuntu:24.04 bash
# 컨테이너 내부에서
pwd
ls
echo 'Hello Ubuntu Container'
exit
# 호스트 WSL에서
docker ps -a
docker start ubuntu-demo
docker exec -it ubuntu-demo bash
# 별도 셸에서 exit 후
docker stop ubuntu-demo
docker attach는 컨테이너 기존 주 프로세스의 입출력에 연결한다. docker exec는 이미 실행 중인 컨테이너에 별도 프로세스를 추가로 실행한다. 주 프로세스 종료는 컨테이너 중지로 이어질 수 있지만 exec로 시작한 별도 셸을 종료한다고 항상 컨테이너가 중지되는 것은 아니다.
- [Docker 설치·상태·hello-world 로그](logs/docker-practice.txt)
- [Ubuntu 컨테이너 실습 로그](logs/ubuntu-practice.txt)
7. 커스텀 NGINX 웹 서버: 빌드, 실행, 접속
7.1 베이스 이미지와 커스텀 포인트
베이스 이미지는 nginx:alpine을 사용했다. 기존 NGINX 웹 서버에 프로젝트 HTML을 복사하여 자신만의 정적 사이트를 제공한다.
FROM nginx:alpine
LABEL org.opencontainers.image.title="my-workstation-web"
ENV APP_ENV=development
COPY app/ /usr/share/nginx/html/
EXPOSE 80
- FROM: NGINX를 이미 포함하는 이미지 사용
- LABEL: 커스텀 이미지의 목적 설명
- ENV: 컨테이너에 환경 변수 설정(이 환경 변수만으로 NGINX 동작이 자동 변경되지는 않음)
- COPY: 호스트의 app/ 정적 콘텐츠를 이미지 빌드 시점에 복사
- EXPOSE 80: 이미지가 사용하는 컨테이너 포트를 문서화. 외부 공개 자체는 -p 옵션으로 수행
현재 저장소의 실제 Dockerfile과 [`app/`](app/) 파일을 참고한다.
7.2 재현 가능한 빌드 및 실행
저장소 루트에서 다음 명령어를 실행한다.
docker build -t my-workstation-web:1.0 .
docker images | grep my-workstation-web

docker run -d --name my-workstation-web -p 8080:80 my-workstation-web:1.0
docker run -d --name my-workstation-web2 -p 8081:80 my-workstation-web:1.0

docker ps
curl -I http://localhost:8080
curl -I http://localhost:8081
docker logs my-workstation-web
docker stats --no-stream
정상이라면 docker images에 my-workstation-web:1.0이 표시되고 docker ps에 8080→80, 8081→80 매핑이 보인다. curl -I의 HTTP 응답 상태가 200 OK이면 접속 성공으로 볼 수 있다. Windows 브라우저에서 http://localhost:8080과 http://localhost:8081에도 접속한다.

포트 매핑 원리: -p 호스트포트:컨테이너포트 형식이다. 브라우저의 localhost:8080 요청이 Docker의 포트 연결을 통해 컨테이너의 NGINX 80 포트로 전달된다. 컨테이너 내부 네트워크와 호스트 네트워크는 기본적으로 분리되므로 이 연결이 필요하다.
- [빌드·실행·포트 확인 로그](logs/web-server-practice.txt)
- [브라우저 접속 스크린샷 폴더](evidence/) — 주소창과 페이지 내용을 함께 캡처
7.3 격리와 네임스페이스
Linux 컨테이너는 네임스페이스 등의 커널 기능을 사용해 프로세스, 네트워크 등의 관점을 격리한다. 예를 들어 컨테이너 내부의 PID와 네트워크 인터페이스는 호스트와 다른 관점으로 보일 수 있다. Docker는 네트워크 격리를 제공하면서 -p로 외부 접속 경로를 선택적으로 연결한다. 이미지로 동일한 구성을 재현할 수 있지만, 컨테이너가 별도의 완전한 가상 머신인 것은 아니다.
8. 바인드 마운트: 파일 수정 즉시 반영
8.1 호스트 / 컨테이너 경로
- 호스트 폴더: 저장소 루트의 bind-site/ ($(pwd)/bind-site)
- 컨테이너 폴더: /usr/share/nginx/html
- readonly: 컨테이너에서 호스트 쪽 콘텐츠를 수정하지 못하게 함. 호스트에서 수정하는 내용은 반영된다.
cd ~/dev-workstation
mkdir -p bind-site
# bind-site/index.html에 Version 1 콘텐츠 준비

docker run -d --name bind-web -p 8082:80 \
  --mount type=bind,source="$(pwd)/bind-site",target=/usr/share/nginx/html,readonly \
  nginx:alpine
curl http://localhost:8082

# bind-site/index.html에서 Version 1을 Version 2로 수정한 후:
curl http://localhost:8082
docker inspect bind-web --format '{{json .Mounts}}'
Bind Mount Version 1에서 Bind Mount Version 2로 응답이 바뀌면 이미지 재빌드 없이 호스트 변경이 반영된 것을 확인할 수 있다. 이때 docker inspect에서 Type: bind에 해당하는 마운트 항목을 확인한다.

재현성 주의: /home/특정사용자/...와 같은 개인 PC 절대 경로를 코드에 고정하지 않고, **프로젝트 루트에서 $(pwd)/bind-site**를 사용한다. WSL Ubuntu의 Linux 파일시스템에서 프로젝트를 실행하는 것을 권장한다. 다른 OS/셸(PowerShell 등)에서는 현재 경로 표현법을 해당 환경에 맞게 바꿔야 한다.
- [바인드 마운트 변경 전후 로그](logs/bind-mount-practice.txt)
- [변경 전후 스크린샷 폴더](evidence/)
9. Docker 볼륨: 컨테이너 삭제 전후 데이터 유지
바인드 마운트는 개발자가 지정한 호스트 경로와 컨테이너 경로를 연결한다. Docker 볼륨은 Docker가 저장 위치를 관리하며 컨테이너와 별개로 데이터를 유지한다.
docker volume create workstation-data

docker run -d --name volume-test1 \
  -v workstation-data:/data ubuntu:24.04 sleep infinity

docker exec volume-test1 sh -c 'echo "Hello Docker Volume" > /data/hello.txt'
docker exec volume-test1 cat /data/hello.txt
# 예상 내용: Hello Docker Volume

docker rm -f volume-test1

docker run -d --name volume-test2 \
  -v workstation-data:/data ubuntu:24.04 sleep infinity

docker exec volume-test2 cat /data/hello.txt
# 동일 내용이 유지되면 영속성 검증 성공

docker volume inspect workstation-data
첫 번째 컨테이너를 삭제한 뒤에도 같은 이름의 볼륨을 두 번째 컨테이너에 연결하면 기존 hello.txt를 읽을 수 있다. 컨테이너의 수명과 영속 데이터의 수명이 분리된다는 의미다.

데이터 보존 주의: 이름 붙은 볼륨은 일반 docker rm만으로 삭제되지 않지만, docker volume rm, 볼륨을 삭제하는 Docker 정리 명령, 저장 장치 손상 시 데이터가 사라질 수 있다. 중요 데이터는 별도 백업해야 한다.

간단 백업 예시 (저장소 루트에서 실행, backup/ 폴더가 생성됨):
mkdir -p backup
docker run --rm -v workstation-data:/data:ro -v "$(pwd)/backup:/backup" ubuntu:24.04 \
  tar -czf /backup/workstation-data.tar.gz -C /data .
ls -lh backup/workstation-data.tar.gz
복원은 기존 데이터가 덮어써질 수 있으므로 새 볼륨에 먼저 시험한다.
docker volume create workstation-restore-test
docker run --rm -v workstation-restore-test:/data -v "$(pwd)/backup:/backup:ro" ubuntu:24.04 \
  tar -xzf /backup/workstation-data.tar.gz -C /data
docker run --rm -v workstation-restore-test:/data:ro ubuntu:24.04 cat /data/hello.txt
- [볼륨 생성·삭제·재연결 검증 로그](logs/volume-practice.txt)
- [볼륨 검증 스크린샷 폴더](evidence/)
10. 포트 충돌 확인과 해결
이미 호스트 포트 8080을 다른 프로세스가 사용하면 -p 8080:80 컨테이너 시작에 실패할 수 있다.
# 실행 중인 Docker 컨테이너의 포트 확인
docker ps --format 'table {{.Names}}\t{{.Ports}}'

# WSL/Linux에서 포트 수신 상태 확인(설치되어 있는 경우)
ss -ltn | grep ':8080'
Windows PowerShell에서 사용할 수 있는 명령어:
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
해결: 기존 8080 포트 사용 프로그램을 먼저 확인하고 필요하지 않은 컨테이너만 중지하거나, 새로운 호스트 포트로 실행한다.
docker run -d --name web-alt -p 8090:80 my-workstation-web:1.0
curl -I http://localhost:8090
대체 포트 사용 시 http://localhost:8090으로 접속한다. 다른 사람의 프로그램이나 중요 서비스를 임의로 종료하지 않는다.
11. Git / GitHub 설정, 원격 연결 및 Push 증거
로컬 개발 경로는 ~/dev-workstation이며 원격 제출 저장소는 아래 주소다.

저장소: https://github.com/pomeg-kkk/cody_ms1
git --version
git config --global init.defaultBranch main
git config --list       # 토큰 등 민감한 설정이 없는지 검토한 뒤 필요한 부분만 공개
git remote -v
git log --oneline -3
git status
GitHub Push에 성공한 실습 화면의 핵심 출력:
To https://github.com/pomeg-kkk/cody_ms1.git
   e65cf98..3d17ad2  main -> main
branch 'main' set up to track 'origin/main'.
이 출력은 로컬 main 커밋이 원격 origin/main에 올라가고 추적 관계가 설정되었음을 뜻한다. VS Code에서는 WSL 프로젝트를 열어 Source Control 창에서 변경 이력과 GitHub 로그인 상태를 확인할 수 있다.

업데이트 방법:
git add README.md evidence logs
git commit -m "Improve mission documentation"
git push origin main
커밋 전에 비밀번호, 인증 토큰, 개인키, 일회용 코드, 개인 경로 및 불필요한 개인정보가 로그와 이미지에 없는지 확인한다.
12. 트러블슈팅 (실제 발생 사례)
12.1 GitHub HTTPS Push 인증 실패
- 문제: git push -u origin main에서 Authentication failed와 No anonymous write access 오류 발생.
- 원인 가설: GitHub의 HTTPS Git 인증에서 일반 계정 비밀번호를 사용했거나 올바른 Git 인증이 설정되지 않음.
- 확인: git remote -v로 원격 주소를 확인했고, gh --version, gh auth login으로 GitHub CLI 인증을 진행함.
- 조치: GitHub CLI의 Login with a web browser로 인증하고 gh auth setup-git을 실행함. 인증 코드와 비밀번호는 공개 로그에 남기지 않음.
- 결과: 이후 Push 진행 시 비밀번호 인증 실패 대신 저장소 이력 및 서버 관련 문제를 확인할 수 있었음.
12.2 README.md 병합 충돌
- 문제: git push에서 (fetch first)가 발생했고 git pull --no-rebase --allow-unrelated-histories origin main 이후 CONFLICT (add/add): Merge conflict in README.md가 나타남.
- 원인 가설: 로컬과 GitHub에 각각 별도의 초기 커밋 및 README.md가 존재함.
- 확인: git fetch origin과 git log --oneline --graph --all -5로 로컬/원격 커밋이 서로 다른 이력임을 확인함.
- 조치: 로컬 README를 보존하기 위해 git checkout --ours README.md를 사용하고, 내용을 확인한 다음 git add README.md 및 병합 커밋을 생성함.
- 결과: 최종 Push 성공. 다만 이 방식은 원격 README만의 내용을 생략하므로 병합 전 두 문서를 비교하는 것이 더 안전함.
12.3 원격 Push 거절 뒤 성공
- 문제: git push -u origin main 과정에서 remote: fatal: error in commit refs 및 [remote rejected] main -> main (failure) 발생.
- 원인 가설: 원격 서버가 커밋 참조를 갱신하는 과정의 일시적 오류.
- 확인: git status는 nothing to commit, working tree clean이었고 git log --oneline -3에서 병합 커밋이 보존됨을 확인함.
- 조치: 로컬 커밋을 유지하고 강제 Push 없이 정상 Push 명령을 재시도함.
- 결과: e65cf98..3d17ad2 main -> main 출력과 branch 'main' set up to track 'origin/main'로 성공 확인.
13. 제출 증거 링크와 최종 검증
검증 항목	실행 명령 또는 증거 위치	확인할 내용
Linux 기본 명령어	[linux-practice.txt](logs/linux-practice.txt)	pwd, ls -la, 파일 생성/이동/삭제
권한 변경	[permission-practice.txt](logs/permission-practice.txt)	파일 600→644, 폴더 700→755
Docker 설치 및 hello-world	[docker-practice.txt](logs/docker-practice.txt)	Docker 버전, 서버 상태, Hello from Docker!
Ubuntu 컨테이너	[ubuntu-practice.txt](logs/ubuntu-practice.txt)	내부 ls, echo, exit, exec
커스텀 이미지/포트/운영	[web-server-practice.txt](logs/web-server-practice.txt)	빌드, 8080/8081 접속, docker ps, 로그, 통계
바인드 마운트	[bind-mount-practice.txt](logs/bind-mount-practice.txt)	Version 1→2 즉시 변경
볼륨 영속성	[volume-practice.txt](logs/volume-practice.txt)	컨테이너 삭제 후 동일 데이터 확인
스크린샷	[](evidence/)	입력·출력 및 브라우저 주소창 포함 여부
GitHub	원격 저장소	원격 main과 README, 증거 파일


최종 제출 전 확인할 사항
1. logs/와 evidence/의 실제 파일 이름이 위 링크와 일치하는지 확인한다. 없는 파일 링크는 실제 이름으로 수정한다.
2. 브라우저 캡처에는 주소창의 포트 번호와 웹 페이지 내용이 함께 보여야 한다.
3. 각 실습 캡처에는 명령어 입력과 결과 출력이 함께 보여야 한다.
4. 평가자가 README만 읽고도 빌드, 포트 매핑, 바인드 마운트, 볼륨 확인을 재현할 수 있는지 검토한다.
5. 로그와 이미지에 비밀번호·토큰 등이 포함되어 있지 않은지 확인한 뒤 Push한다.
14. 재현 및 정리 시 주의사항
처음 실행하는 평가자는 저장소를 복제한 뒤 Docker Desktop과 WSL 연동이 켜진 상태에서 아래 명령어로 웹 서버를 재현할 수 있다.
git clone https://github.com/pomeg-kkk/cody_ms1.git
cd cody_ms1
docker build -t my-workstation-web:1.0 .
docker run -d --name web-review -p 8090:80 my-workstation-web:1.0
curl -I http://localhost:8090
브라우저 접속 주소는 http://localhost:8090이다. 컨테이너가 이미 존재하거나 포트가 사용 중인 경우 컨테이너 이름 또는 호스트 포트를 변경한다. 검증 후 실습 컨테이너를 정리할 때는 docker stop <컨테이너명>과 docker rm <컨테이너명>을 사용하되, 영속성 검증에 사용한 볼륨은 별도 보관한다.