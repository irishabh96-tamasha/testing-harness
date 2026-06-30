import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const DEITIES = [
  { id: "all", name: "All Gods", sort: 0 },
  { id: "hanuman", name: "Hanuman ji", sort: 1 },
  { id: "ram", name: "Ram ji", sort: 2 },
  { id: "durga", name: "Durga Ma", sort: 3 },
  { id: "ganesh", name: "Ganesh Ji", sort: 4 },
];

interface SeedStatus {
  deityId: string;
  i: number;
  authorName: string;
  authorSubtitle: string;
  tagline: string;
  likes: number;
  views: number;
}

const STATUSES: SeedStatus[] = [
  { deityId: "all", i: 1, authorName: "Aditya Nath", authorSubtitle: "Srinath Builders • 9876543210", tagline: "Own your Dream Home", likes: 24000, views: 140000 },
  { deityId: "all", i: 2, authorName: "Meera Devi", authorSubtitle: "Sankalp Foundation • 9811122233", tagline: "Seva for all", likes: 8200, views: 54000 },
  { deityId: "all", i: 3, authorName: "Ravi Kumar", authorSubtitle: "Bharat Motors • 9700011122", tagline: "Drive home the festive offer", likes: 152000, views: 1300000 },
  { deityId: "hanuman", i: 1, authorName: "Bajrang Dal Trust", authorSubtitle: "Temple Committee • 9000011111", tagline: "Tuesday Aarti live", likes: 64000, views: 480000 },
  { deityId: "hanuman", i: 2, authorName: "Sundar Sweets", authorSubtitle: "Since 1985 • 9000022222", tagline: "Prasad boxes available", likes: 12000, views: 90000 },
  { deityId: "ram", i: 1, authorName: "Ayodhya Darshan", authorSubtitle: "Yatra Tours • 9001112223", tagline: "Book your pilgrimage", likes: 98000, views: 760000 },
  { deityId: "ram", i: 2, authorName: "Ramayan Path", authorSubtitle: "Cultural Society • 9002223334", tagline: "Evening recital today", likes: 21000, views: 130000 },
  { deityId: "durga", i: 1, authorName: "Shakti Mandap", authorSubtitle: "Puja Samiti • 9003334445", tagline: "Pandal inauguration", likes: 110000, views: 920000 },
  { deityId: "durga", i: 2, authorName: "Devi Vastra", authorSubtitle: "Boutique • 9004445556", tagline: "Festive sarees 40% off", likes: 33000, views: 210000 },
  { deityId: "ganesh", i: 1, authorName: "Siddhivinayak Seva", authorSubtitle: "Trust • 9005556667", tagline: "Modak distribution drive", likes: 87000, views: 640000 },
  { deityId: "ganesh", i: 2, authorName: "Ganpati Decor", authorSubtitle: "Event Co • 9006667778", tagline: "Book eco-friendly idols", likes: 25000, views: 160000 },
];

const SIGNS: { id: string; name: string; reading: string }[] = [
  { id: "aries", name: "Aries", reading: "A bold start favours you today — act on the idea you have been postponing, but pause before reacting in conversations." },
  { id: "taurus", name: "Taurus", reading: "Steady effort pays off. Money matters look stable; a loved one appreciates your patience this evening." },
  { id: "gemini", name: "Gemini", reading: "Your words carry weight today. A chance chat opens a useful door — keep your plans flexible." },
  { id: "cancer", name: "Cancer", reading: "Home and heart take centre stage. Trust your intuition on a decision you have been avoiding." },
  { id: "leo", name: "Leo", reading: "You shine in a group setting. Share credit generously and an opportunity for leadership follows." },
  { id: "virgo", name: "Virgo", reading: "Details you notice today save the day for someone. Make time to rest your busy mind." },
  { id: "libra", name: "Libra", reading: "Balance returns to a tense situation. A fair compromise leaves everyone lighter." },
  { id: "scorpio", name: "Scorpio", reading: "Focus your intensity on one goal. A quiet act of devotion brings unexpected peace." },
  { id: "sagittarius", name: "Sagittarius", reading: "Adventure calls — say yes to a small new experience. Optimism is your strength today." },
  { id: "capricorn", name: "Capricorn", reading: "Discipline turns a long plan into progress. Recognition for past work is on its way." },
  { id: "aquarius", name: "Aquarius", reading: "An original idea finds support. Connect with community and share your vision freely." },
  { id: "pisces", name: "Pisces", reading: "Creativity flows. Listen to a dream or feeling — it points you toward a kind choice." },
];

const BOOKS = [
  { id: "ramayan", title: "Valmiki Ramayan", author: "Maharishi Valmiki", category: "Stotram", sort: 0 },
  { id: "gita", title: "Shrimad Bhagavad Gita", author: "Ved Vyasa", category: "Stotram", sort: 1 },
  { id: "vishnu-puran", title: "Shri Vishnu Puran", author: "Ved Vyasa", category: "Stotram", sort: 2 },
  { id: "hanuman-chalisa", title: "Hanuman Chalisa", author: "Tulsidas", category: "Chalisa", sort: 3 },
];

// Placeholder recitation audio (public sample MP3s — NOT real recitation).
const AUDIO = [
  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
];

interface SeedChapter {
  bookId: string;
  section: string;
  sectionSort: number;
  title: string;
  body: string;
}

const para =
  "This passage is presented for demonstration. In the full library each chapter " +
  "carries the complete verse and its meaning. Read at your own pace, and tap Listen " +
  "Audio to hear the recitation. May this reading bring peace and focus to your day.";

function chaptersFor(
  bookId: string,
  sections: { name: string; titles: string[] }[],
): SeedChapter[] {
  const out: SeedChapter[] = [];
  sections.forEach((sec, si) => {
    sec.titles.forEach((t) => {
      out.push({ bookId, section: sec.name, sectionSort: si, title: t, body: para });
    });
  });
  return out;
}

const CHAPTERS: SeedChapter[] = [
  ...chaptersFor("ramayan", [
    {
      name: "Bala Kanda (Book of Childhood)",
      titles: [
        "Adhyaya 1 — Narada tells Valmiki the story of Rama",
        "Adhyaya 2 — The birth of the Ramayana",
        "Adhyaya 3 — The princes of Ayodhya",
      ],
    },
    {
      name: "Ayodhya Kanda (Book of Ayodhya)",
      titles: [
        "Adhyaya 1 — The promise of the king",
        "Adhyaya 2 — The journey to the forest",
      ],
    },
  ]),
  ...chaptersFor("gita", [
    {
      name: "Chapter 1 — Arjuna Vishada Yoga",
      titles: ["Verse 1 — The field of Kurukshetra", "Verse 2 — Arjuna's doubt"],
    },
    {
      name: "Chapter 2 — Sankhya Yoga",
      titles: ["Verse 1 — The eternal soul", "Verse 2 — Duty without attachment"],
    },
  ]),
];

const WP_DEITIES = ["hanuman", "ram", "durga", "ganesh"];
const WP_COLLECTIONS = ["live", "new", "trending"];

const WALLPAPERS = WP_DEITIES.flatMap((deityId) =>
  WP_COLLECTIONS.flatMap((collection, ci) =>
    [0, 1].map((n) => ({
      id: `wp-${deityId}-${collection}-${n}`,
      deityId,
      imageUrl: `https://picsum.photos/seed/wp-${deityId}-${collection}-${n}/400/700`,
      collection,
      sort: ci * 2 + n,
    })),
  ),
);

const RINGTONE_TITLES: Record<string, string[]> = {
  hanuman: ["Hanuman Chalisa", "Bajrang Baan", "Sankat Mochan"],
  ram: ["Shri Ram Stuti", "Raghupati Raghav", "Ram Dhun"],
  durga: ["Durga Saptashati", "Ambe Maa Aarti", "Mahishasura Mardini"],
  ganesh: ["Ganesh Vandana", "Vakratunda Mahakaya", "Sukhkarta Dukhharta"],
};

const RINGTONES = WP_DEITIES.flatMap((deityId, di) =>
  RINGTONE_TITLES[deityId].map((title, n) => ({
    id: `rt-${deityId}-${n}`,
    deityId,
    title,
    imageUrl: `https://picsum.photos/seed/rt-${deityId}-${n}/200`,
    audioUrl: AUDIO[(di + n) % AUDIO.length],
    plays: 100000 * (di + 1) + n * 23000,
    downloads: 30000 * (di + 1) + n * 7000,
    sort: n,
  })),
);

async function main() {
  // Idempotent reseed.
  await prisma.status.deleteMany();
  await prisma.deity.deleteMany();
  await prisma.horoscope.deleteMany();
  await prisma.chapter.deleteMany();
  await prisma.book.deleteMany();
  await prisma.wallpaper.deleteMany();
  await prisma.ringtone.deleteMany();

  await prisma.wallpaper.createMany({ data: WALLPAPERS });
  await prisma.ringtone.createMany({ data: RINGTONES });

  await prisma.book.createMany({
    data: BOOKS.map((b) => ({
      id: b.id,
      title: b.title,
      author: b.author,
      coverUrl: `https://picsum.photos/seed/book-${b.id}/300/420`,
      category: b.category,
      sort: b.sort,
    })),
  });

  await prisma.chapter.createMany({
    data: CHAPTERS.map((c, i) => ({
      id: `${c.bookId}-${i}`,
      bookId: c.bookId,
      section: c.section,
      sectionSort: c.sectionSort,
      title: c.title,
      body: c.body,
      audioUrl: AUDIO[i % AUDIO.length],
      sort: i,
    })),
  });

  await prisma.horoscope.createMany({
    data: SIGNS.map((s, i) => ({
      id: s.id,
      name: s.name,
      reading: s.reading,
      sort: i,
    })),
  });

  await prisma.deity.createMany({
    data: DEITIES.map((d) => ({
      id: d.id,
      name: d.name,
      imageUrl: `https://picsum.photos/seed/${d.id}/120`,
      sort: d.sort,
    })),
  });

  await prisma.status.createMany({
    data: STATUSES.map((s) => ({
      id: `${s.deityId}-${s.i}`,
      deityId: s.deityId,
      imageUrl: `https://picsum.photos/seed/${s.deityId}${s.i}/600/900`,
      authorName: s.authorName,
      authorSubtitle: s.authorSubtitle,
      tagline: s.tagline,
      authorAvatarUrl: `https://picsum.photos/seed/${s.deityId}${s.i}avatar/100`,
      likes: s.likes,
      views: s.views,
      sort: s.i,
    })),
  });

  const deities = await prisma.deity.count();
  const statuses = await prisma.status.count();
  const horoscopes = await prisma.horoscope.count();
  const books = await prisma.book.count();
  const chapters = await prisma.chapter.count();
  const wallpapers = await prisma.wallpaper.count();
  const ringtones = await prisma.ringtone.count();
  console.log(
    `Seeded ${deities} deities, ${statuses} statuses, ${horoscopes} horoscopes, ${books} books, ${chapters} chapters, ${wallpapers} wallpapers, ${ringtones} ringtones.`,
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
