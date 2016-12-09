require 'pg'

TITLES = ["Roasted Brussels Sprouts",
  "Fresh Brussels Sprouts Soup",
  "Brussels Sprouts with Toasted Breadcrumbs, Parmesan, and Lemon",
  "Cheesy Maple Roasted Brussels Sprouts and Broccoli with Dried Cherries",
  "Hot Cheesy Roasted Brussels Sprout Dip",
  "Pomegranate Roasted Brussels Sprouts with Red Grapes and Farro",
  "Roasted Brussels Sprout and Red Potato Salad",
  "Smoky Buttered Brussels Sprouts",
  "Sweet and Spicy Roasted Brussels Sprouts",
  "Smoky Buttered Brussels Sprouts",
  "Brussels Sprouts and Egg Salad with Hazelnuts"]

COMMENTS = [["Do not eat this", 8],
  ["Go and get yourself a big bowl of pasta", 1],
  ["This would go well with some sugar", 1]]

#WRITE CODE TO SEED YOUR DATABASE AND TABLES HERE
def db_connection
  begin
    connection = PG.connect(dbname: "brussels_sprouts_recipes")
    yield(connection)
  ensure
    connection.close
  end
end

db_connection do |conn|
  conn.exec("DROP TABLE IF EXISTS recipes CASCADE")
  conn.exec("DROP TABLE IF EXISTS comments CASCADE")

  conn.exec("CREATE TABLE recipes(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
  );")

  conn.exec("CREATE TABLE comments(
    id SERIAL PRIMARY KEY,
    comment VARCHAR(255),
    recipe_id INT REFERENCES recipes(id)
  );")

  TITLES.each do |title|
    conn.exec_params("INSERT INTO recipes(name) VALUES ($1)", [title])
  end

  COMMENTS.each do |comment_array|
    conn.exec_params("INSERT INTO comments(comment, recipe_id) VALUES ($1, $2)", [comment_array[0], comment_array[1]])
  end

  count_recipes = conn.exec("SELECT count(*) FROM recipes")
  count_recipes.each do |num|
    puts "There are #{num["count"]} recipes!"
  end

  count_comments = conn.exec("SELECT count(*) FROM comments")
  count_comments.each do |num|
    puts "There are #{num["count"]} comments!"
  end


  comment_sub = conn.exec("SELECT recipes.name AS name, count(*) AS count FROM recipes JOIN comments ON recipes.id = comments.recipe_id GROUP BY recipes.id")
  comment_sub.each do |sub|
    puts "#{sub["name"]} has #{sub["count"].to_i} comments"
  end

  # comment_sub = conn.exec("SELECT recipes.name, COMMENT_RESULTS.count FROM recipes LEFT JOIN (SELECT recipe_id AS recipe_foreign, count(*) AS count FROM comments GROUP BY recipe_id) AS COMMENT_RESULTS ON recipes.id = COMMENT_RESULTS.recipe_foreign")
  # comment_sub.each do |sub|
  #   puts "#{sub["name"]} has #{sub["count"].to_i} comments"
  # end

  comment_recipe = conn.exec("SELECT recipes.name, comments.comment FROM comments LEFT JOIN recipes ON recipes.id = comments.recipe_id")
  comment_recipe.each do |recipe|
    puts "Recipe Name: #{recipe["name"]}, Comment: #{recipe["comment"]}"
  end

  conn.exec_params("INSERT INTO recipes(name) VALUES ($1)", ['Brussels Sprouts with Goat Cheese'])

  recipe_name = conn.exec("SELECT recipes.id FROM recipes WHERE recipes.name = 'Brussels Sprouts with Goat Cheese'")
  recipe_name = recipe_name.to_a[0]["id"]
  conn.exec_params("INSERT INTO comments(comment, recipe_id) VALUES ($1, $2)", ['I hate goats', recipe_name])
  conn.exec_params("INSERT INTO comments(comment, recipe_id) VALUES ($1, $2)", ['Noah loves these problems BUT ESPECIALLY brussels sprouts', recipe_name])

end
