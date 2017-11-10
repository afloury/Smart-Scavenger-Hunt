FROM python:3.6

ADD requirements.txt .
RUN python3 -m pip install -r requirements.txt

ADD src /SmartScavengerHunt_lrid-generator/
WORKDIR /SmartScavengerHunt_lrid-generator/

CMD ["python", "-u", "main.py"]
