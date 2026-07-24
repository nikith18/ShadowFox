import os

def remove_comments():
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                
                new_lines = []
                for line in lines:
                    if line.lstrip().startswith('//'):
                        continue
                    
                    new_line = line
                    if '//' in new_line and not 'http://' in new_line and not 'https://' in new_line:
                        parts = new_line.split('//')
                        new_line = parts[0].rstrip() + '\n'
                    new_lines.append(new_line)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.writelines(new_lines)

if __name__ == '__main__':
    remove_comments()
