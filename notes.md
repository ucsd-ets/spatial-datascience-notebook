### 12/1/24 Notes:

1. ```ipywidgets``` installed via conda and pip have a habit of not being the same version. This results in ```HTML()``` throwing the following error:

```
Failed to load model class 'HTMLModel' from module '@jupyter-widgets/controls'
Error: Module @jupyter-widgets/controls, version ^1.5.0 is not registered, however,         2.0.0 is
```

Solution: Allow conda to install ipywidgets, do not install via requirements.txt unless required. If it is, make sure the versions match.

2. Installing certain python packages breaks our python installation (failed to import sqlite3, prevents JLab startup and breaks the image)

Solution: Install them using pip. A more permanent solution can be found but at this time only a certain number of python packages seem to trigger this issue. 

3. IPython.notebook.* no longer exists in JupyterLab/NB7+.

Solution: There is no 1:1 drop-in alternative to this as far as I'm aware. However, here are a few potential replacements:

- https://gist.github.com/gnestor/f1893e0226ced227e910f11b769adc06

- The ```pylab``` extension: https://stackoverflow.com/questions/68585590/run-all-below-action-in-jupyterlab-programatically/71944193#71944193

- Using the following snippet is a decent start:

```
%%javascript
    console.log('hello')
```

This logs "hello" to the developer console.

```
from IPython.display import Javascript

html_widget = HTML()
display(html_widget)

# Use Javascript to set the innerHTML of the widget
display(Javascript("""
    var test_variable = 'Hello from Javascript!';
    element.innerHTML = test_variable;
"""))

# Python can now access the value of the widget
print("Value from JavaScript:", html_widget.value)
```

This displays an HTML widget to get similar behavior to the original ```IPython.notebook.kernel.execute()``` method.