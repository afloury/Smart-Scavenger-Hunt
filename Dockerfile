FROM python:3.6

ADD requirements.txt .
RUN python3 -m pip install -r requirements.txt

ADD src /SmartScavengerHunt_orchestrator/
WORKDIR /SmartScavengerHunt_orchestrator/

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
    "main:app" \
]
