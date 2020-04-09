# DrifterCode.com

A blog written in Elm Pages.

The comment system is written with Firebase Cloud Functions written in TypeScript and `purify-ts`.

Visit the site at: [https://driftercode.com](https://driftercode.com)

Note to self: Manually optimize images with this command until Elm Pages does it on build time.

```bash
mogrify -strip -interlace Plane -gaussian-blur 0.05 -quality 85% *.jpg
```

Ref: https://stackoverflow.com/questions/7261855/recommendation-for-compressing-jpg-files-with-imagemagick