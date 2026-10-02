#!/bin/bash

SESSION="workspace_cientifico"
VENV_DIR="venv_lab"

# 1. Configurar el entorno de Python si no existe
if [ ! -d "$VENV_DIR" ]; then
    echo "Inicializando entorno virtual y descargando librerías..."
    python3 -m venv $VENV_DIR
    source $VENV_DIR/bin/activate
    pip install --upgrade pip
    
    # Machine Learning & Data Science
    pip install numpy pandas scikit-learn torch
    
    # Gráficas e interactividad
    pip install matplotlib seaborn plotly jupyterlab
    
    # Astronomía, Física y Óptica (Análisis de imágenes y filtros)
    pip install astropy photutils scipy opencv-python scikit-image
    
    echo "Entorno Python listo."
else
    source $VENV_DIR/bin/activate
fi

# 2. Iniciar y configurar tmux
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Crear sesión en segundo plano
    tmux new-session -d -s $SESSION

    # Habilitar el mouse para hacer clic en paneles, redimensionarlos y hacer scroll
    tmux set-option -t $SESSION -g mouse on

    # Configurar el copiado al portapapeles (requiere xclip instalado)
    tmux set-option -t $SESSION -s set-clipboard on
    tmux bind-key -t $SESSION -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -sel clip -i"

    # Dividir la pantalla en 6 paneles
    tmux split-window -t $SESSION -h
    tmux split-window -t $SESSION -h
    tmux select-layout -t $SESSION even-horizontal
    
    tmux select-pane -t $SESSION:0.0
    tmux split-window -t $SESSION -v
    tmux select-pane -t $SESSION:0.2
    tmux split-window -t $SESSION -v
    tmux select-pane -t $SESSION:0.4
    tmux split-window -t $SESSION -v

    # Ajustar a una cuadrícula perfecta
    tmux select-layout -t $SESSION tiled

    # Activar el entorno virtual simultáneamente en los 6 paneles
    tmux set-window-option -t $SESSION synchronize-panes on
    tmux send-keys -t $SESSION "source $VENV_DIR/bin/activate; clear" C-m
    tmux set-window-option -t $SESSION synchronize-panes off
    
    # ---> NUEVO: Iniciar JupyterLab en el panel 5 (abajo a la derecha) <---
    tmux send-keys -t $SESSION:0.5 "jupyter lab" C-m
    
    # Dejar el foco en el primer panel (arriba a la izquierda) para que empieces a trabajar
    tmux select-pane -t $SESSION:0.0
fi

# Entrar a la sesión
tmux attach-session -t $SESSION