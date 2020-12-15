#include <iostream>
#include <vector>
#include <thread>
#include <pthread.h>
#include <semaphore.h>
#include <memory>
#include <chrono>

using namespace std;

const int visitorsNum = 15;
const int maxVisitorsNum = 50;
const int maxVisitorsNumEachPainting = 10;
const int maxWatchedVisitors = 10;
const int paintingsNum = 5;

/// <summary>
/// Структура для работы с картинами
/// </summary>
struct Painting {
    Painting() {
        sem_init(&pic_sem, 0, maxVisitorsNumEachPainting);
    }

    sem_t pic_sem{};
};

/// <summary>
/// Структура для удобной работы с картинами
/// </summary>
struct ArtGallery {
    vector<Painting> paintings = vector<Painting>(paintingsNum);
};

/// <summary>
/// Класс, отвечающий за работу охранника
/// </summary>
class Security {
public:
    Security() {
        maxSem = sem_t();
        sem_init(&maxSem, 0, maxVisitorsNum);
    }

    /// <summary>
    /// Метод для допуска посетителей к картинам
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    ArtGallery* ArtGallery_get(int id) {
        cout << "Посетитель " << id << " ждет своей очереди" << endl;
        sem_wait(&maxSem);
        cout << "Охранник разрешил подойти к картине посетителю " << id << endl;
        return artGallery.get();
    }

    /// <summary>
    /// Метод для выпуска посетителей из галереи 
    /// </summary>
    /// <param name="id"></param>
    void leaveGallery(int id) {
        cout << "Посетитель " << id << " вышел из картинной галереи" << endl;
        sem_post(&maxSem);
    }

private:
    sem_t maxSem{};
    unique_ptr<ArtGallery> artGallery = make_unique<ArtGallery>();
};
Security security;

/// <summary>
/// Класс посетителей
/// </summary>
class Visitor {
public:
    Visitor(int id) : id(id) {}

    // Работа потока
    void start() {
        pthread_create(&thread, nullptr, PaintingsWatching, (void*)&id);
    }

    // Окончание работы потока
    void join() const {
        pthread_join(thread, nullptr);
    }

private:
    int id; // Номер посетителя 
    pthread_t thread;

    /// <summary>
    /// Метод для работы с посетителями у картин
    /// </summary>
    /// <param name="param"></param>
    /// <returns></returns>
    static void* PaintingsWatching(void* param) {
        int id = *((int*)param);
        auto artGallery = security.ArtGallery_get(id);

        int maxVisitors = rand() % maxWatchedVisitors;
        for (int i = 0; i < maxVisitors; ++i) {
            int paintingID = rand() % artGallery->paintings.size();
            cout << " Посетитель " << id << " ждет подхода к картине " << paintingID << endl;
            sem_t& sem = artGallery->paintings[paintingID].pic_sem;
            sem_wait(&sem);
            cout << " Посетитель " << id << " смотрит картину " << paintingID << endl;
            this_thread::sleep_for(chrono::seconds(1)); // wait
            sem_post(&sem);
            cout << " Посетитель " << id << " закончил смотреть картину " << paintingID << endl;
        }
        security.leaveGallery(id);
        return nullptr;
    }
};


int main() {
    // Подключаем русский язык
    setlocale(LC_ALL, "Russian");

    vector<Visitor> visitors;

    for (int i = 0; i < visitorsNum; i++) {
        visitors.push_back(i);
    }

    for (int i = 0; i < visitors.size(); i++) {
        visitors[i].start();
    }

    for (int i = 0; i < visitors.size(); i++) {
        visitors[i].join();
    }

    return 0;
}
