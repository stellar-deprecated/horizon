package horizon

import (
	"net/url"
	"time"

	"github.com/garyburd/redigo/redis"
	"github.com/stellar/horizon/log"
)

func initRedis(app *App) {
	if app.config.RedisURL == "" {
		return
	}

	redisURL, err := url.Parse(app.config.RedisURL)

	if err != nil {
		log.Panic(err)
	}

	app.redis = &redis.Pool{
		MaxIdle:      3,
		IdleTimeout:  240 * time.Second,
		Dial:         dialRedis(redisURL),
		TestOnBorrow: pingRedis,
	}

	// test the connection
	c := app.redis.Get()
	defer c.Close()

	_, err = c.Do("PING")

	if err != nil {
		log.Panic(err)
	}
}

func dialRedis(redisURL *url.URL) func() (redis.Conn, error) {
	return func() (redis.Conn, error) {
		c, err := redis.Dial("tcp", redisURL.Host)
		if err != nil {
			return nil, err
		}

		if redisURL.User == nil {
			return c, err
		}

		if pass, ok := redisURL.User.Password(); ok {
			if _, err := c.Do("AUTH", pass); err != nil {
				c.Close()
				return nil, err
			}
		}

		return c, err
	}
}

func pingRedis(c redis.Conn, t time.Time) error {
	_, err := c.Do("PING")
	return err
}

func init() {
	appInit.Add("redis", initRedis, "app-context", "log")
}
