import re

html = open('modals.html', encoding='utf-8').read()

# Fix the stray div in add-work-modal
html = html.replace('<div>\n                    <div><label class=\"block text-sm font-bold text-gray-700 mb-1\">Mulai</label>', '<div><label class=\"block text-sm font-bold text-gray-700 mb-1\">Mulai</label>')

def inject_headers(html_str):
    out = []
    lines = html_str.split('\n')
    current_modal = None
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.search(r'id=\"([a-zA-Z0-9_-]+-modal)\"', line)
        if m: current_modal = m.group(1)
        
        if '<div class=\"px-8 py-6 border-b border-gray-100\">' in line:
            title = re.search(r'<h3[^>]*>(.*?)</h3>', lines[i+1]).group(1)
            icon = 'file-text'
            if 'Pekerjaan' in title: icon = 'briefcase'
            if 'Aktivitas' in title: icon = 'check-circle'
            if 'Edit' in title: icon = 'edit-3'
            
            replacement = f'''            <div class=\"px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50\">
                <h3 class=\"text-lg font-bold text-gray-900 flex items-center gap-2\">
                    <i data-lucide=\"{icon}\" class=\"w-5 h-5 text-red-800\"></i>
                    {title}
                </h3>
                <button type=\"button\" onclick=\"closeModal('{current_modal}')\" class=\"text-gray-400 hover:text-gray-600 transition-colors p-1.5 rounded-lg hover:bg-gray-100\">
                    <i data-lucide=\"x\" class=\"w-5 h-5\"></i>
                </button>
            </div>'''
            out.append(replacement)
            i += 2 # skip next two lines
        else:
            out.append(line)
        i += 1
    return '\n'.join(out)

html = inject_headers(html)

# Now make the input borders subtle like React
html = re.sub(r'class=\"w-full px-4 py-2 border rounded-lg outline-none([^\"]*)\"', r'class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm transition-all\1"', html)

# Modify buttons to be more professional
html = re.sub(r'class=\"flex-1 px-6 py-3 border rounded-lg font-bold\"', 'class=\"flex-1 px-4 py-2.5 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors flex items-center justify-center gap-2 text-sm\"', html)
html = re.sub(r'class=\"flex-1 px-6 py-3 bg-red-800 text-white rounded-lg font-bold\"', 'class=\"flex-1 px-4 py-2.5 bg-red-800 text-white rounded-lg font-medium hover:bg-red-900 transition-colors flex items-center justify-center gap-2 text-sm\"', html)

open('modals_fixed.html', 'w', encoding='utf-8').write(html)
