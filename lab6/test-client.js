const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    console.log("Підключення до бази PostgreSQL встановлено\n");

    const newMovie = await prisma.movies.create({
        data: {
            title: 'Дюна: Частина друга',
            price: 150.00
        }
    });
    console.log(`Створено новий фільм: ${newMovie.title} (ID: ${newMovie.movie_id})`);

    const newReview = await prisma.reviews.create({
        data: {
            rating: 5,
            comment: 'Просто неймовірний фільм, візуал вражає!',
            movie_id: newMovie.movie_id
        }
    });
    console.log(`Відгук успішно додано! (ID відгуку: ${newReview.review_id})`);

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