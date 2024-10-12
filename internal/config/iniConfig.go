package config

import "gopkg.in/ini.v1"

// LoadConfig /**
func LoadConfig() (*ini.File, error) {
	cfg, err := ini.Load("internal/resources/development.ini")
	if err != nil {
		return nil, err
	}
	return cfg, nil
}
