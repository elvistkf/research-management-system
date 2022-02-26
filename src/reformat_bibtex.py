import os
import sys

def reformat(path, new_path):
    bibtex_path = path
    rf_bibtex_path = new_path
    open(rf_bibtex_path, 'w').write('')

    skipped_field = [
        'series', 'keywords', 'local-url', 'url', 'publisher'
    ]

    with open(bibtex_path, 'r') as fin:
        with open(rf_bibtex_path, 'a') as fout:
            for line in fin:
                linecontent = line
                if ('title' in line) and ('booktitle' not in line):
                    linecontent = linecontent.replace('{{', '{').replace('}}', '}')
                if 'lqg' in line:
                    linecontent = linecontent.replace('lqg', 'LQG')
                for f in skipped_field:
                    tmp = f + ' = {'
                    if tmp in line:
                        linecontent = ''
                        continue
                    
                fout.write(linecontent)

if __name__ == "__main__":
    root_dir = sys.argv[1]
    bib_folder = sys.argv[2]
    bib_file = sys.argv[3]
    reformat(f'{root_dir}/{bib_folder}/{bib_file}.bib', f'{root_dir}/{bib_folder}/{bib_file}_rf.bib')
    # reformat("./Bibliography/ref.bib", "./Bibliography/ref_rf.bib")
    print("Reformat Completed")
