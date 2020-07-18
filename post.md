Jupyter is a tool for running interactive notebooks; basically add Python with Markdown and you've got Jupyter. if you haven't used it before, I recommend you do. 

In this post, I'm going to show you how to deploy a Jupyter Notebook server on Heroku using Docker. 

## The big caveat
Jupyter has the ability to create new notebooks and they will 100% save on your deployed docker-based Jupyter server... but they will **disappear** as soon as you deploy a new version. That's because containers, by their very nature, are ephemeral by default. 

This caveat doesn't mean we shouldn't do this... it just means it is a HUGE consideration when using this guide over something like http://colab.research.google.com.

Near the bottom, I'll show you how to package all your Jupyter contents, download it, and unpackage it again when you deploy.


### Final Project Structure

```
cfe_jupyter
|   Dockerfile
│   Pipfile  
│   Pipfile.lock
│
└───conf
│   │   jupyter.py
│   
└───scripts
    │   Dockerfile
    │   d_build.sh
    |   d_run.sh
    |   deploy.sh
    |   entrypoint.sh
```


### `Dockerfile`

```
FROM python:3.8.2-slim

ENV APP_HOME /app
WORKDIR ${APP_HOME}

COPY . ./

RUN pip install pip pipenv --upgrade
RUN pipenv install --skip-lock --system --dev

CMD ["./scripts/entrypoint.sh"]
```

### `Pipfile`
```
[[source]]
name = "pypi"
url = "https://pypi.org/simple"
verify_ssl = true

[dev-packages]

[packages]
jupyter = "*"

[requires]
python_version = "3.8"
```

### `scripts/d_build.sh`
```bash
docker build -t cfe-jupyter -f Dockerfile .
```


### `scripts/d_run.sh`
```bash
docker run --env PORT=8888 -it -p 8888:8888 cfe-jupyter
```


### `scripts/deploy.sh`
```bash
heroku container:push web
heroku container:release web
```


### `scripts/entrypoint.sh`

```bash
#!/bin/bash

/usr/local/bin/jupyter notebook --config=./conf/jupyter.py
```



### `conf/jupyter.py`
```python
import os
c = get_config()
# Kernel config
c.IPKernelApp.pylab = 'inline'  # if you want plotting support always in your notebook
# Notebook config
c.NotebookApp.notebook_dir = 'nbs'
c.NotebookApp.allow_origin = u'cfe-jupyter.herokuapp.com' # put your public IP Address here
c.NotebookApp.ip = '*'
c.NotebookApp.allow_remote_access = True
c.NotebookApp.open_browser = False
# ipython -c "from notebook.auth import passwd; passwd()"
c.NotebookApp.password = u'sha1:8da45965a489:86884d5b174e2f64e900edd129b5ef0d2f784a65'
c.NotebookApp.port = int(os.environ.get("PORT", 8888))
c.NotebookApp.allow_root = True
c.NotebookApp.allow_password_change = True
c.ConfigurableHTTPProxy.command = ['configurable-http-proxy', '--redirect-port', '80']
```


### Export

##### Zip all files.
```
!tar chvfz notebook.tar.gz *
```

##### Unzip all files:
```
!tar -xv -f notebook.tar.gz
```

