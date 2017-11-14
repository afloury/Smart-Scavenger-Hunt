FROM python:3.6

ENV GOOGLE_APPLICATION_CREDENTIALS key.json

ADD requirements.txt .
RUN python3 -m pip install -r requirements.txt

ADD src /SmartScavengerHunt_game/
WORKDIR /SmartScavengerHunt_game/

EXPOSE 80
CMD [\
    "gunicorn", \
    "--pid", "gunicorn.pid", \
\
    "--bind", ":80", \
    "--backlog", "2000", \
\
    "--workers", "8", \
    "--worker-connections", "2000", \
\
    "--log-level", "debug", \
    "--capture-output", \
\
    "main:app" \
]
