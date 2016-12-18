import vim
import json

msg_str = vim.eval('l:line')

try:
    msg = json.loads(msg_str)
    result = {}

    if not 'message' in msg:
        raise ValueError()

    result['text'] = msg['message']['message']
    for i in range(len(msg['message']['children'])):
        result['text'] += ': ' if i == 0 else ','
        result['text'] += msg['message']['children'][i]['message']

    result['lnum'] = 0
    result['col'] = 0
    if len(msg['message']['spans']) > 0:
        result['lnum'] = msg['message']['spans'][0]['line_start']
        result['col'] = msg['message']['spans'][0]['column_start']

    result['type'] = 'E' if msg['message']['level'] == 'error' else 'W'

    vim.command("let l:result = json_decode('%s')" % json.dumps(result))
except ValueError:
    pass
