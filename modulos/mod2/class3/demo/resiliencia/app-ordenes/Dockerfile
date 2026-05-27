FROM python:3.11-slim

WORKDIR /app

RUN pip install --upgrade pip
RUN pip install flask requests

COPY app.py .

EXPOSE 5001

CMD ["python", "app.py"]