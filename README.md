# jupyker-cpu
Docker image for AI: Jupyter Notebook, Keras, Tensorflow, Scikit-learn, Python, and more, on Ubuntu.
Same as [ea167/jupyker](https://hub.docker.com/r/ea167/jupyker) repo, but for CPU without gpu support.


##### Launch
Adjust the volume mount (`-v` option) and launch with:

```
    docker run -it -d -p=6006:6006 -p=8888:8888 \
        -v=~/DockerShared/JupykerShared:/host  ea167/jupyker-cpu
```

###  

and then connect your browser to:
* http://localhost:8888 for Jupyter Notebook
* http://localhost:6006 for TensorBoard
