FROM python:3.10-alpine3.13
LABEL maintainer="hassansaber460@gmail.com"

# منع Python من تخزين ملفات الـ pyc
ENV PYTHONUNBUFFERED=1

# نسخ ملفات المتطلبات
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# نسخ الكود الرئيسي
COPY ./app /app

# ضبط مسار العمل
WORKDIR /app

# تعيين المنفذ الافتراضي
EXPOSE 8000

# متغير ARG لتحديد بيئة التطوير
ARG DEV=false

# تثبيت المتطلبات
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps\
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ] ; \
        then echo "--DEV BUILD--" && /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# إضافة /py/bin إلى الـ PATH
ENV PATH="/py/bin:$PATH"

# تعيين المستخدم الافتراضي
USER django-user
