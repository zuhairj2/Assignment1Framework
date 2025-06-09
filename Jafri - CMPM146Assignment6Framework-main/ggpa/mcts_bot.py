from __future__ import annotations
import math
import random
from agent import Agent
from battle import BattleState
from card import Card
from action.action import EndAgentTurn, PlayCard
from game import GameState
from ggpa.ggpa import GGPA
from config import Verbose


# You only need to modify the TreeNode!
class TreeNode:
    # You can change this to include other attributes. 
    # param is the value passed via the -p command line option (default: 0.5)
    # You can use this for e.g. the "c" value in the UCB-1 formula

    def __init__(self, param, parent=None):
        # Exploration constant (c in UCB-1)
        self.param = param

        # Pointers for tree structure
        self.parent = parent
        self.children: list[TreeNode] = []

        # MCTS statistics
        self.visits = 0
        self.total_reward = 0.0

        # Initialized on first visit
        self.untried_actions: list | None = None

        # The PlayCard/EndAgentTurn action that led from parent → this node
        # Root’s action_from_parent remains None
        self.action_from_parent = None

    def step(self, state: BattleState):
        node = self
        state_copy = state.copy_undeterministic()
        visited_nodes = [node]

        # 1) SELECTION: Initialize untried_actions on first visit
        if node.untried_actions is None:
            node.untried_actions = state_copy.get_actions().copy()

        while True:
            if state_copy.ended():
                # We reached a terminal state
                break

            if node.untried_actions and len(node.untried_actions) > 0:
                # This node has at least one action not expanded yet
                break

            # Fully expanded & non-terminal → select child via UCB-1
            node = node._select_child_ucb()
            # Convert wrapper action → GameAction, then step
            state_copy.step(node.action_from_parent.to_action(state_copy))
            visited_nodes.append(node)

            if node.untried_actions is None:
                node.untried_actions = state_copy.get_actions().copy()

        # 2) EXPANSION: If not terminal and there are untried actions, expand exactly one
        if (not state_copy.ended()) and node.untried_actions and len(node.untried_actions) > 0:
            action = node.untried_actions.pop()
            child = TreeNode(self.param, parent=node)
            child.action_from_parent = action
            node.children.append(child)

            # Convert wrapper → GameAction, then step the copy
            state_copy.step(action.to_action(state_copy))
            node = child
            visited_nodes.append(node)

            node.untried_actions = state_copy.get_actions().copy()

        # 3) ROLLOUT: Play random legal moves until terminal
        reward = self.rollout(state_copy)

        # 4) BACKPROPAGATION: Propagate reward up the visited path
        for visited in visited_nodes:
            visited.visits += 1
            visited.total_reward += reward

    def _select_child_ucb(self) -> TreeNode:
        best_score = -float("inf")
        best_child = None

        for child in self.children:
            if child.visits == 0:
                score = float("inf")
            else:
                exploit = child.total_reward / child.visits
                explore = math.sqrt(math.log(self.visits) / child.visits)
                score = exploit + self.param * explore

            if score > best_score:
                best_score = score
                best_child = child

        return best_child

    def rollout(self, rollout_state: BattleState) -> float:
        state = rollout_state
        while not state.ended():
            possible = state.get_actions()
            action = random.choice(possible)
            state.step(action.to_action(state))
        return state.score()

    def get_best(self, state: BattleState) -> PlayCard | EndAgentTurn:
        best_avg = -float("inf")
        best_action = None

        for child in self.children:
            if child.visits > 0:
                avg = child.total_reward / child.visits
            else:
                avg = 0.0

            if avg > best_avg:
                best_avg = avg
                best_action = child.action_from_parent

        if best_action is None:
            legal = state.get_actions()
            return random.choice(legal).to_action(state)

        return best_action.to_action(state)

    def print_tree(self, indent: int = 0):
        prefix = " " * indent
        if self.action_from_parent is None:
            avg = (self.total_reward / self.visits) if self.visits > 0 else 0.0
            print(f"{prefix}[ROOT] (visits: {self.visits}, avg: {avg:.3f})")
        else:
            avg = (self.total_reward / self.visits) if self.visits > 0 else 0.0
            print(f"{prefix}{self.action_from_parent} (visits: {self.visits}, avg: {avg:.3f})")

        for child in self.children:
            child.print_tree(indent + 2)


# You do not have to modify the MCTS Agent (but you can)
class MCTSAgent(GGPA):
    def __init__(self, iterations: int, verbose: bool, param: float):
        self.iterations = iterations
        self.verbose = verbose
        self.param = param

    # REQUIRED METHOD
    def choose_card(self, game_state: GameState, battle_state: BattleState) -> PlayCard | EndAgentTurn:
        actions = battle_state.get_actions()
        if len(actions) == 1:
            return actions[0].to_action(battle_state)

        root = TreeNode(self.param)
        for _ in range(self.iterations):
            sample_state = battle_state.copy_undeterministic()
            sample_state.agent = self  # allow to_action() to choose targets
            root.step(sample_state)

        best_action = root.get_best(battle_state)
        if self.verbose:
            root.print_tree()

        return best_action

    # REQUIRED METHOD: all scenarios only have one enemy
    def choose_agent_target(self, battle_state: BattleState, list_name: str, agent_list: list[Agent]) -> Agent:
        return agent_list[0]

    # REQUIRED METHOD: no card targeting needed
    def choose_card_target(self, battle_state: BattleState, list_name: str, card_list: list[Card]) -> Card:
        return card_list[0]
