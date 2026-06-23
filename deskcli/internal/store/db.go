package store

import (
	"database/sql"
	"os"
	"path/filepath"

	_ "modernc.org/sqlite"
)

type ContainerRecord struct {
	Name     string
	Image    string
	Engine   string
	Password string
	PortSSH  int
	PortRDP  int
	PortNX   int
	PortVNC  int
}

type DB struct{ db *sql.DB }

func Open(dataDir string) (*DB, error) {
	if err := os.MkdirAll(dataDir, 0755); err != nil {
		return nil, err
	}
	db, err := sql.Open("sqlite", filepath.Join(dataDir, "deskapi.db"))
	if err != nil {
		return nil, err
	}
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS containers (
		name TEXT PRIMARY KEY, image TEXT, engine TEXT, password TEXT,
		port_ssh INTEGER, port_rdp INTEGER, port_nx INTEGER, port_vnc INTEGER
	)`)
	if err != nil {
		return nil, err
	}
	return &DB{db}, nil
}

func (d *DB) Save(r *ContainerRecord) error {
	_, err := d.db.Exec(
		`INSERT OR REPLACE INTO containers (name,image,engine,password,port_ssh,port_rdp,port_nx,port_vnc) VALUES (?,?,?,?,?,?,?,?)`,
		r.Name, r.Image, r.Engine, r.Password, r.PortSSH, r.PortRDP, r.PortNX, r.PortVNC)
	return err
}

func (d *DB) Get(name string) (*ContainerRecord, error) {
	r := &ContainerRecord{}
	err := d.db.QueryRow(
		`SELECT name,image,engine,password,port_ssh,port_rdp,port_nx,port_vnc FROM containers WHERE name=?`, name,
	).Scan(&r.Name, &r.Image, &r.Engine, &r.Password, &r.PortSSH, &r.PortRDP, &r.PortNX, &r.PortVNC)
	return r, err
}

func (d *DB) UpdatePassword(name, password string) error {
	_, err := d.db.Exec(`UPDATE containers SET password=? WHERE name=?`, password, name)
	return err
}

func (d *DB) Delete(name string) error {
	_, err := d.db.Exec(`DELETE FROM containers WHERE name=?`, name)
	return err
}

func (d *DB) UsedPorts() map[int]bool {
	used := make(map[int]bool)
	rows, err := d.db.Query(`SELECT port_ssh,port_rdp,port_nx,port_vnc FROM containers`)
	if err != nil {
		return used
	}
	defer rows.Close()
	for rows.Next() {
		var a, b, c, e int
		if rows.Scan(&a, &b, &c, &e) == nil {
			used[a], used[b], used[c], used[e] = true, true, true, true
		}
	}
	return used
}

func (d *DB) Close() error { return d.db.Close() }
