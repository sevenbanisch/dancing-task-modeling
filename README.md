# Dancing‑Task Modeling

## Overview (abstract)

The repository implements a minimal reinforcement‑learning environment that captures a *dyadic* “dancing” interaction. Two agents share a one‑dimensional space and repeatedly choose among three possible actions:

* **avoid** – increase the distance to the partner by one unit
* **stay** – keep the current distance unchanged
* **approach** – decrease the distance by one unit

The distance `d` is bounded between `0` (agents are on top of each other) and a configurable maximum `d_max`. When an action would move the system outside these bounds it is automatically replaced by `stay`.

### Preference (reward) function

Each agent has an *ideal* distance `Δ` (its “preferred distance”) and a tolerance window `Δ_range`. A reward is computed from the current distance `d` using a configurable function (`exp`, `normdif` or `abs`). The reward captures how close the actual distance is to the agent’s preferred distance and is used as the reinforcement signal.

### Learning dynamics

Agents learn via **Q‑learning**:

* State = current distance `d` (discretised to integer steps).
* Action‑value table `Q` stores expected future reward for every combination of:
  * acting agent
  * selected action
  * current distance
  * last action of the other agent (the model conditions on the partner’s previous move).
* After each turn the selected action is evaluated, the distance is updated, the reward is computed, and the corresponding Q‑entry is updated with a learning rate `α`.
* Action selection follows a soft‑max (Boltzmann) policy with inverse temperature `β`, turning the Q‑values into a probability distribution.

### Interaction protocol

A round consists of two turns (one for each agent). The agents act alternately, each observing the shared distance and the partner’s last action, then selecting an action, updating the shared state, receiving a reward and updating its Q‑table.

### Outputs

* **Distance time‑series** – a vector that records the distance after each turn, useful for visualising convergence or oscillatory behaviour.
* **Q‑tables** – the learned action‑value tensors that encode each agent’s policy.
* **Visualization** – MATLAB/Octave scripts plot the distance trajectory together with colour‑coded reward heat‑maps for each agent, making it easy to see how the learned behaviour relates to the underlying preferences.

## Scope of the repository

* **Model core** – MATLAB / Octave files (`agent.m`, `dancing_task.m`, `preference.m`, `plot_dancing_task.m`).
* **Exploratory UI** – a lightweight Streamlit app (`app.py`) that loads the experimental CSV output, lets the user filter by move number, and visualises the distance trace.
* **Experimental variants** – alternative scripts (`dancing_task_sven.m`, `fourthmodel.m`) illustrate different parameter settings or a more procedural implementation.

The project is deliberately lightweight: it provides a complete reinforcement‑learning loop, a configurable reward function, and a visual assessment tool, all of which can be extended for research on multi‑agent coordination, preference learning, or bounded‑action environments.

---

*No code snippets are included here; the detailed implementation can be inspected in the source files.*