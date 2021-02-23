FROM public.ecr.aws/lambda/python:3.8

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src .

# handler chosen during Lambda creation
CMD ["handlers.handler"]
