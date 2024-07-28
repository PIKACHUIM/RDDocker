#!/bin/bash
DATE=$(date --rfc-3339='seconds')
git add .
git commit -m "Updated at ${DATE}"
git push origin
git push github
