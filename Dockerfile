FROM python:3.6

ENV GOOGLE_APPLICATION_CREDENTIALS key.json

ADD requirements.txt .
RUN python3 -m pip install -r requirements.txt

ADD src /SmartScavengerHunt_game/
WORKDIR /SmartScavengerHunt_game/

RUN mkdir /SmartScavengerHunt_game/pictures

ENV TIMEOUT 30
EXPOSE 80
CMD ["python3", "-u", "main.py"]