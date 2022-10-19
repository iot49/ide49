# TODO

## balena-cli

https://github.com/balena-io/balena-cli/blob/master/INSTALL-LINUX.m

```bash
curl -L --output x.zip https://github.com/balena-io/balena-cli/releases/download/v14.5.0/balena-cli-v14.5.0-macOS-x64-standalone.zip
```

## jupyter

```bash
# reboot & shutdown links missing on newer versions of Ubuntu
# ln -f -s -- ../bin/systemctl /sbin/reboot
# ln -f -s -- ../bin/systemctl /sbin/shutdown
```

```
[Build]   jupyter-base   Step 8/10 : RUN mamba install --quiet --yes     jupyterlab-spellchecker  && mamba clean --quiet --all -f -y
[Build]   jupyter-base    ---> Running in a3bf3594e3f0
[Build]   jupyter-base     Package                    Version  Build         Channel                Size
[Build]   jupyter-base   ─────────────────────────────────────────────────────────────────────────────────
[Build]   jupyter-base     Install:
[Build]   jupyter-base   ─────────────────────────────────────────────────────────────────────────────────
[Build]   jupyter-base     + jupyterlab-spellchecker    0.7.2  pyhd8ed1ab_0  conda-forge/noarch      5MB
[Build]   jupyter-base     Summary:
[Build]   jupyter-base     Install: 1 packages
[Build]   jupyter-base     Total download: 5MB
[Build]   jupyter-base   ─────────────────────────────────────────────────────────────────────────────────
[Build]   jupyter-base   Preparing transaction: ...working... done
[Build]   jupyter-base   Verifying transaction: ...working... WARNING conda.core.path_actions:verify(962): Unable to create environments file. Path not writable.
[Build]   jupyter-base     environment location: /home/iot/.conda/environments.txt
[Build]   jupyter-base   done
[Build]   jupyter-base   Executing transaction: ...working... WARNING conda.core.envs_manager:register_env(51): Unable to register environment. Path not writable or missing.
[Build]   jupyter-base     environment location: /opt/conda
[Build]   jupyter-base     registry file: /home/iot/.conda/environments.txt
[Build]   jupyter-base   done
[Build]   jupyter-base   Removing intermediate container a3bf3594e3f0
[Build]   jupyter-base    ---> e782cb673875
[Build]   jupyter-base   Step 9/10 : RUN pip install --default-timeout=1000     asyncio-mqtt     bleak
[Build]   jupyter-base    ---> Running in 791cedcd58c4
[Build]   jupyter-base   WARNING: The directory '/home/iot/.cache/pip' or its parent directory is not owned or is not writable by the current user. The cache has been disabled. Check the permissions and owner of that directory. If executing pip with sudo, you should use sudo's -H flag.
[Build]   jupyter-base   Collecting asyncio-mqtt
[Build]   jupyter-base     Downloading asyncio_mqtt-0.13.0-py3-none-any.whl (14 kB)
```

```bash
./build.py deploy.amd64 --nocache --build
```