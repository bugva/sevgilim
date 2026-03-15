# Senin İçin 💕

Sevgiline özel, oyunlu tek sayfalık site. Tarayıcıda açıp hemen kullanabilirsin.

## Nasıl kullanılır?

1. **index.html** dosyasını çift tıkla veya tarayıcıya sürükleyip bırak — site açılır.
2. Kişiselleştirmek için **index.html** dosyasını bir metin editörüyle aç ve en üstteki `<script>` içinde şu kısmı bul:

```javascript
const CONFIG = {
  partnerName: 'Sevgilim',  // Sevgilinin ismini yaz
  message: `Buraya senin mesajını yaz.
Birden fazla satır da olabilir. 💕`,
  photoPaths: [
    'photos/1.jpg',
    'photos/2.jpg',
    'photos/3.jpg'
    // İstediğin kadar ekle
  ]
};
```

- **partnerName**: Karşılama ekranında görünecek isim.
- **message**: Oyunu bitirdikten sonra açılan karttaki gizli mesaj.
- **photoPaths**: Oyunda düşecek fotoğraflar. `photos` klasörüne dosyaları koy (1.jpg, 2.jpg vb.). Listeyi boş bırakırsan oyunda kalpler görünür.

3. Değişiklikleri kaydedip sayfayı yenile.

## Oyun

- "Oyunu Başlat"a tıkla.
- Yukarıdan düşen fotoğraflara (veya kalplere) tıklayarak 10 tane topla.
- 10 tanesini toplayınca gizli mesajın ve konfeti açılır.

## Fotoğraflar

1. **photos** klasörüne sevgilinin fotoğraflarını ekle (örn. 1.jpg, 2.jpg, 3.jpg).
2. **index.html** içinde `CONFIG.photoPaths` listesini bu dosya adlarına göre düzenle.
3. `photoPaths` listesini boş bırakırsan oyunda kalpler kullanılır.

İstersen dosyayı e‑posta ile gönderebilir veya bir web sunucusuna koyup link olarak paylaşabilirsin.
