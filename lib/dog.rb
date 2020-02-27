class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                age INTEGER
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
        SQL

        DB[:conn].execute(sql)
    end

    def self.new_from_db(array_attributes)
        init_hash = {
            :id => array_attributes[0],
            :name => array_attributes[1],
            :breed => array_attributes[2]
        }

        Dog.new(init_hash)
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1;
        SQL

        result = DB[:conn].execute(sql, name)
        new_from_db(result[0])
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?;
        SQL

        DB[:conn].execute(sql, name, breed, id)
    end

    def save 
        if id
            dog = update
        else
            sql = <<-SQL 
                INSERT INTO dogs (name, breed)
                VALUES (?, ?);
            SQL

            DB[:conn].execute(sql, name, breed)

            @id = DB[:conn].execute(
                "SELECT last_insert_rowid() FROM dogs"
            )[0][0]

            dog = self
        end

        dog
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save
        new_dog
    end

    def self.find_by_id(id_input)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1;
        SQL

        result = DB[:conn].execute(sql, id_input)[0]

        new_from_db(result)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?;
        SQL

        result = DB[:conn].execute(sql, name, breed)

        if !result.empty?
            dog_data = result[0]
            dog = Dog.new({:id => dog_data[0], :name => dog_data[1], :breed => dog_data[2]})
        else
            dog = Dog.create({:name => name, :breed => breed})
        end
        
        dog
    end
end