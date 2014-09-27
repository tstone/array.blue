---
title: Converting PNG Images into HTML
date: Nov 18, 2010
tags: python
category: python
---

A while back I wrote a short python script to take any PNG image file and convert it into pure HTML.  Yes, pure HTML.

This actually started as an office joke with the query of how do we put the company logo into emails for people who don’t have images enabled.  It was a natural downward progression of jokes that eventually lead to converting the image into HTML.  Aaaaaand as any dynamic language programmer in a Microsoft shop I knew I could probably whip up something in an hour or so.

My first few attempts didn’t work too well because I actually generated too much HTML.  It seems that after about 2.75MB of HTML, browsers tend to choke and die when rendering it.  So after the first initial hour of getting it to work, the remaining time was spent on compressing the HTML into a manageable portion for the browser.

The script uses `<b>` tags to represent rows and `<a>` tags to represent individual pixels (chosen because they’re short).

The script is smart enough to figure out that if two “pixels” next to each other are the same color, instead of adding a new `<a>` tag, it can simply increase the width of the `<a>` tag to the left.

```python
#!/usr/bin/env python

#
# Converts any PNG into pure HTML
#

import png, array
reader = png.Reader(filename='wedding.png')   # << -- enter the image path here
width, height, pixels, metadata = reader.read()

r = 0
g = 0
h = 0
w = 0
h = 0
count = 0
building_color = ''
last_color = ''
carrying_width = 0
id = 0

html =  '<style type="text/css">\n'
html += '    div { overflow: hidden; background-color: white; }\n'
html += '    div > b { height: 1px; width: 110%; display: block; margin: 0; padding: 0; overflow: hidden; }\n'
html += '    div > b > a { height: 1px; width: 1px; display: block; float: left; background-color: #ffffff; margin: 0; padding: 0; }\n'
html += '</style>\n\n'
html += '<div style="position: relative; height: %spx; width: %spx;">\n' % (height, width)

for row in pixels:

    html += '<b>'

    for pixel in row:

        id += 1
        color = '%x' % pixel
        if len(color) == 1:
            color = '0%s' % color

        building_color += color
        count += 1

        if count == 3:
            count = 0
            carrying_width += 1

            # Convert to shorthand (if can)
            if building_color[0:1] == building_color[1:2] and building_color[2:3] == building_color[3:4] and building_color[4:5] == building_color[5:6]:
                building_color = '%s%s%s' % (building_color[0:1], building_color[2:3], building_color[4:5])

            if building_color != last_color:
                if len(last_color) > 0:
                    style = ''
                    if not last_color == 'fff' or not last_color == 'ffffff':
                        style += 'background:#%s;' % last_color
                    if carrying_width > 1:
                        style += 'width:%spx;' % str(carrying_width)

                    if len(style) > 0:
                        html += '<a style="%s"/>' % style
                    else:
                        html += '<a/>'

                carrying_width = 0

            last_color = building_color
            building_color = ''

    if len(last_color) > 0:
        carrying_width += 1
        html += '<a style="background:#%s;' % last_color
        if carrying_width > 1:
            html += 'width:%spx;' % str(carrying_width)
        html += '"/>'

    # Reset on each row
    carrying_width = 0
    last_color = ''
    html += "</b>"
    h += 1

html += '</div>'
print html
```
