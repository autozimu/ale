import neovim
import json
from datetime import datetime

@neovim.plugin
class Limit:
    def __init__(self, vim):
        self.vim = vim

    @neovim.function('AleLintersRustCargoCheckHandle')
    def function_handler(self, args):
        output = []
        for line in args[0]:
            try:
                msg = json.loads(line)
            except ValueError:
                continue

            if msg['reason'] != 'compiler-message':
                continue

            alemsg = {}

            alemsg['text'] = msg['message']['message']
            for i in range(len(msg['message']['children'])):
                alemsg['text'] += ': ' if i == 0 else ','
                alemsg['text'] += msg['message']['children'][i]['message']

            alemsg['lnum'] = 0
            alemsg['col'] = 0
            if len(msg['message']['spans']) > 0:
                alemsg['lnum'] = msg['message']['spans'][0]['line_start']
                alemsg['col'] = msg['message']['spans'][0]['column_start']

            alemsg['type'] = 'E' if msg['message']['level'] == 'error' else 'W'

            output.append(alemsg)

        self.vim.vars['l:AleLintersRustCargoCheckHandleOutput'] = output
