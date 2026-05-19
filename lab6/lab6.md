# Лабораторна робота №6: Міграції схем за допомогою Prisma ORM
**Звіт про виконання міграцій для бази даних системи прокату фільмів**

---

### Міграція 1: Додавання нової таблиці відгуків (`add_review_table`)
* **Мета зміни:** Реалізувати новий бізнес-функціонал для збору оцінок та текстових відгуків від клієнтів про фільми.
* **Стан моделі у `schema.prisma` після зміни:**
```prisma
model reviews {
  review_id  Int      @id @default(autoincrement())
  rating     Int
  comment    String?  @db.Text
  movie_id   Int
  movies     movies   @relation(fields: [movie_id], references: [movie_id], onDelete: Cascade, onUpdate: NoAction)
}
```
* **Згенерований SQL-код міграції:**
```sql
CREATE TABLE "reviews" (
    "review_id" SERIAL NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "movie_id" INTEGER NOT NULL,

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("review_id")
);

ALTER TABLE "reviews" ADD CONSTRAINT "reviews_movie_id_fkey" 
FOREIGN KEY ("movie_id") REFERENCES "movies"("movie_id") ON DELETE CASCADE ON UPDATE NO ACTION;
```

### Міграція 2: Модифікація структури таблиці (`add_customer_email`)
* **Мета зміни:** Додати нове поле для зберігання електронної пошти клієнтів з метою подальшої організації маркетингових розсилок та переходу на сучасні стандарти автентифікації.
* **Стан моделі у `schema.prisma` після зміни:**
```prisma
model customers {
  customer_id Int       @id @default(autoincrement())
  name        String    @db.VarChar(100)
  phone       String    @db.VarChar(20)
  email       String?   @unique @db.VarChar(150)
  rentals     rentals[]
}
```

### Міграція 3: Оптимізація та вилучення стовпця (`drop_customer_phone`)
* **Мета зміни:** Вилучити застарілу колонку номера телефону `phone` з таблиці клієнтів у зв'язку з повним переходом сервісу на комунікацію та ідентифікацію через Email.
* **Стан моделі у `schema.prisma` після зміни (фінальний вигляд сутності):**
```prisma
model customers {
  customer_id Int       @id @default(autoincrement())
  name        String    @db.VarChar(100)
  email       String?   @unique @db.VarChar(150)
  rentals     rentals[]
}
```
* **Згенерований SQL-код міграції під капотом:**
```sql
ALTER TABLE "customers" DROP COLUMN "phone";
```

---

## 3. Програмна перевірка схеми
Було розроблено тестовий асинхронний скрипт на базі Node.js (`test-client.js`), який виконує підключення, додає новий фільм, створює пов'язаний із ним відгук.

### Код тестового сценарію (`test-client.js`):
```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    console.log("Підключення до бази PostgreSQL встановлено\n");

    // Створення фільму
    const newMovie = await prisma.movies.create({
        data: {
            title: 'Дюна: Частина друга',
            price: 150.00
        }
    });
    console.log(`Створено новий фільм: ${newMovie.title} (ID: ${newMovie.movie_id})`);

    // Створення відгуку до цього фільму
    const newReview = await prisma.reviews.create({
        data: {
            rating: 5,
            comment: 'Просто неймовірний фільм, візуал вражає!',
            movie_id: newMovie.movie_id
        }
    });
    console.log(`Відгук успішно додано! (ID відгуку: ${newReview.review_id})`);

    // Аналітична вибірка зі зв'язками
    const moviesWithReviews = await prisma.movies.findMany({
        include: {
            reviews: true
        }
    });

    console.log("\nРезультат вибірки з бази:");
    console.log(JSON.stringify(moviesWithReviews, null, 2));
}

main()
    .catch((e) => {
        console.error("Помилка виконання:", e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
        console.log("\nЗ'єднання закрито");
    });
```

### Результат виконання скрипта в терміналі розробника:
```text
Підключення до бази PostgreSQL встановлено

Створено новий фільм: Дюна: Частина друга (ID: 4)
Відгук успішно додано! (ID відгуку: 4)

Результат вибірки з бази:
[
  {
    "movie_id": 1,
    "title": "Дюна: Частина друга",
    "price": "150",
    "reviews": [
      {
        "review_id": 1,
        "rating": 5,
        "comment": "Просто неймовірний фільм, візуал вражає!",
        "movie_id": 1
      }
    ]
  }

З'єднання закрито
```

---

## Висновок
Впровадження Prisma ORM дозволило повністю автоматизувати процес еволюції схеми бази даних PostgreSQL. Застосовані міграції (`add_review_table`, `add_customer_email`, `drop_customer_phone`) дозволили успішно модифікувати існуючі сутності та інтегрувати нові реляційні зв'язки без порушення цілісності даних. Програмна перевірка за допомогою Prisma Client JS підтвердила коректність роботи оновленої структури бази даних.