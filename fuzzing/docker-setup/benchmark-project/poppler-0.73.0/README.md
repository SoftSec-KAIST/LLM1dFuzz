# Various ways to Trigger CVE-2019-7310

1. With pdftocairo (From initial bug report)

```bash
./pdftocairo -png @@
```

2. With pdfimages, pdftoppm (From Magma's choice)

```bash
./pdfimages @@ /tmp/out
./pdftoppm -mono -cropbox @@
```

Note that both share the same root cause.
I will follow pdfimages 
