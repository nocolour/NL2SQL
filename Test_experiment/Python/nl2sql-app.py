import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import json
import re
import os
import openai
from dotenv import load_dotenv
import threading

# Load environment variables from .env file
load_dotenv()

class NL2SQLApp:
    def __init__(self, root):
        self.root = root
        self.root.title("NL2SQL Query System")
        self.root.geometry("1200x800")
        
        # Initialize OpenAI API key
        self.openai_api_key = os.getenv("OPENAI_API_KEY", "")
        
        # MySQL connection settings
        self.db_config = {
            "host": "",
            "port": "3306",
            "user": "",
            "password": "",
            "database": ""
        }
        
        # Load saved configurations if available
        self.load_config()
        
        # Create menu
        self.create_menu()
        
        # Create main UI
        self.create_widgets()
        
        # SQL blacklist for safety
        self.sql_blacklist = [
            "DELETE", "DROP", "UPDATE", "INSERT", "ALTER", "TRUNCATE", 
            "CREATE", "RENAME", "REPLACE", "GRANT", "REVOKE"
        ]
    
    def create_menu(self):
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Database Configuration", command=self.show_config_window)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About", command=self.show_about)
    
    def create_widgets(self):
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Query input area
        query_frame = ttk.LabelFrame(main_frame, text="Natural Language Query", padding="10")
        query_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.query_text = scrolledtext.ScrolledText(query_frame, height=4, wrap=tk.WORD)
        self.query_text.pack(fill=tk.X, padx=5, pady=5)
        
        # Example queries
        examples_frame = ttk.Frame(query_frame)
        examples_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Label(examples_frame, text="Examples:").pack(side=tk.LEFT, padx=5)
        
        example_queries = [
            "Show me the top 5 customers by order value",
            "What products have the highest sales in the last month?",
            "Count orders by status"
        ]
        
        self.example_var = tk.StringVar()
        example_combo = ttk.Combobox(examples_frame, textvariable=self.example_var, values=example_queries, width=50)
        example_combo.pack(side=tk.LEFT, padx=5)
        example_combo.bind("<<ComboboxSelected>>", self.use_example)
        
        # Buttons frame
        buttons_frame = ttk.Frame(query_frame)
        buttons_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Button(buttons_frame, text="Execute Query", command=self.process_query).pack(side=tk.LEFT, padx=5)
        ttk.Button(buttons_frame, text="Clear", command=self.clear_query).pack(side=tk.LEFT, padx=5)
        
        # Status indicator
        self.status_var = tk.StringVar()
        self.status_var.set("Ready")
        self.status_indicator = ttk.Label(buttons_frame, textvariable=self.status_var)
        self.status_indicator.pack(side=tk.RIGHT, padx=5)
        
        # Generated SQL area
        sql_frame = ttk.LabelFrame(main_frame, text="Generated SQL", padding="10")
        sql_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.sql_text = scrolledtext.ScrolledText(sql_frame, height=4, wrap=tk.WORD)
        self.sql_text.pack(fill=tk.X, padx=5, pady=5)
        
        # Results area with notebook for different views
        results_frame = ttk.LabelFrame(main_frame, text="Results", padding="10")
        results_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Create notebook for different result views
        self.results_notebook = ttk.Notebook(results_frame)
        self.results_notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Tab 1: Data view
        self.data_frame = ttk.Frame(self.results_notebook)
        self.results_notebook.add(self.data_frame, text="Data")
        
        # Create treeview for data results
        self.result_tree = ttk.Treeview(self.data_frame)
        self.result_tree.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Add scrollbar to treeview
        tree_scrollbar = ttk.Scrollbar(self.data_frame, orient="vertical", command=self.result_tree.yview)
        tree_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.result_tree.configure(yscrollcommand=tree_scrollbar.set)
        
        # Tab 2: Chart view
        self.chart_frame = ttk.Frame(self.results_notebook)
        self.results_notebook.add(self.chart_frame, text="Chart")
        
        # Tab 3: Summary view
        self.summary_frame = ttk.Frame(self.results_notebook)
        self.results_notebook.add(self.summary_frame, text="Summary")
        
        self.summary_text = scrolledtext.ScrolledText(self.summary_frame, wrap=tk.WORD)
        self.summary_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
    
    def show_config_window(self):
        """Show database configuration window"""
        config_window = tk.Toplevel(self.root)
        config_window.title("Database Configuration")
        config_window.geometry("400x350")
        config_window.transient(self.root)  # Make window modal
        config_window.grab_set()
        
        # Create form for database configuration
        config_frame = ttk.Frame(config_window, padding="20")
        config_frame.pack(fill=tk.BOTH, expand=True)
        
        # Database configuration fields
        ttk.Label(config_frame, text="MySQL Host:").grid(row=0, column=0, sticky=tk.W, pady=5)
        host_entry = ttk.Entry(config_frame, width=30)
        host_entry.grid(row=0, column=1, pady=5)
        host_entry.insert(0, self.db_config["host"])
        
        ttk.Label(config_frame, text="Port:").grid(row=1, column=0, sticky=tk.W, pady=5)
        port_entry = ttk.Entry(config_frame, width=30)
        port_entry.grid(row=1, column=1, pady=5)
        port_entry.insert(0, self.db_config["port"])
        
        ttk.Label(config_frame, text="Username:").grid(row=2, column=0, sticky=tk.W, pady=5)
        user_entry = ttk.Entry(config_frame, width=30)
        user_entry.grid(row=2, column=1, pady=5)
        user_entry.insert(0, self.db_config["user"])
        
        ttk.Label(config_frame, text="Password:").grid(row=3, column=0, sticky=tk.W, pady=5)
        password_entry = ttk.Entry(config_frame, width=30, show="*")
        password_entry.grid(row=3, column=1, pady=5)
        password_entry.insert(0, self.db_config["password"])
        
        ttk.Label(config_frame, text="Database Name:").grid(row=4, column=0, sticky=tk.W, pady=5)
        db_entry = ttk.Entry(config_frame, width=30)
        db_entry.grid(row=4, column=1, pady=5)
        db_entry.insert(0, self.db_config["database"])
        
        # OpenAI API key
        ttk.Label(config_frame, text="OpenAI API Key:").grid(row=5, column=0, sticky=tk.W, pady=5)
        api_entry = ttk.Entry(config_frame, width=30)
        api_entry.grid(row=5, column=1, pady=5)
        api_entry.insert(0, self.openai_api_key)
        
        # Test connection button
        ttk.Button(config_frame, text="Test Connection", 
                  command=lambda: self.test_connection(
                      host_entry.get(), port_entry.get(), user_entry.get(), 
                      password_entry.get(), db_entry.get()
                  )).grid(row=6, column=0, columnspan=2, pady=10)
        
        # Save configuration button
        ttk.Button(config_frame, text="Save Configuration", 
                  command=lambda: self.save_config(
                      host_entry.get(), port_entry.get(), user_entry.get(), 
                      password_entry.get(), db_entry.get(), api_entry.get(),
                      config_window
                  )).grid(row=7, column=0, columnspan=2, pady=5)
        
        # Cancel button
        ttk.Button(config_frame, text="Cancel", 
                  command=config_window.destroy).grid(row=8, column=0, columnspan=2, pady=5)
    
    def test_connection(self, host, port, user, password, database):
        """Test MySQL connection with provided credentials"""
        try:
            conn = mysql.connector.connect(
                host=host,
                port=port,
                user=user,
                password=password,
                database=database
            )
            conn.close()
            messagebox.showinfo("Success", "Database connection successful!")
        except Exception as e:
            messagebox.showerror("Connection Error", f"Failed to connect to database: {str(e)}")
    
    def save_config(self, host, port, user, password, database, api_key, window):
        """Save configuration to file and update current settings"""
        self.db_config = {
            "host": host,
            "port": port,
            "user": user,
            "password": password,
            "database": database
        }
        
        self.openai_api_key = api_key
        os.environ["OPENAI_API_KEY"] = api_key
        
        # Save to file
        config_data = {
            "database": self.db_config,
            "openai_api_key": self.openai_api_key
        }
        
        try:
            with open("nl2sql_config.json", "w") as f:
                json.dump(config_data, f)
            messagebox.showinfo("Success", "Configuration saved successfully!")
            window.destroy()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save configuration: {str(e)}")
    
    def load_config(self):
        """Load configuration from file if it exists"""
        try:
            if os.path.exists("nl2sql_config.json"):
                with open("nl2sql_config.json", "r") as f:
                    config_data = json.load(f)
                
                self.db_config = config_data.get("database", self.db_config)
                self.openai_api_key = config_data.get("openai_api_key", "")
                os.environ["OPENAI_API_KEY"] = self.openai_api_key
        except Exception as e:
            messagebox.showwarning("Warning", f"Failed to load configuration: {str(e)}")
    
    def process_query(self):
        """Process the natural language query and execute it"""
        query = self.query_text.get("1.0", tk.END).strip()
        
        if not query:
            messagebox.showwarning("Warning", "Please enter a query.")
            return
        
        # Check if configuration is set
        if not self.db_config["host"] or not self.db_config["user"] or not self.openai_api_key:
            messagebox.showwarning("Warning", "Please configure database and API settings first.")
            self.show_config_window()
            return
        
        # Update status
        self.status_var.set("Processing...")
        self.root.update_idletasks()
        
        # Run the query processing in a separate thread to avoid UI freezing
        threading.Thread(target=self.execute_query_process, args=(query,), daemon=True).start()
    
    def execute_query_process(self, query):
        try:
            # Step 1: Convert natural language to SQL using GPT-4o-mini
            sql_query = self.nl_to_sql(query)
            
            # Update SQL text area
            self.root.after(0, lambda: self.sql_text.delete("1.0", tk.END))
            self.root.after(0, lambda: self.sql_text.insert(tk.END, sql_query))
            
            # Step 2: Validate SQL for safety
            if not self.validate_sql(sql_query):
                self.root.after(0, lambda: self.status_var.set("Ready"))
                return
            
            # Step 3: Execute SQL on MySQL database
            df = self.execute_sql(sql_query)
            
            # Step 4: Display results
            self.root.after(0, lambda: self.display_results(df))
            
            # Step 5: Generate summary
            summary = self.generate_summary(query, sql_query, df)
            self.root.after(0, lambda: self.summary_text.delete("1.0", tk.END))
            self.root.after(0, lambda: self.summary_text.insert(tk.END, summary))
            
            # Step 6: Generate chart if appropriate
            self.root.after(0, lambda: self.generate_chart(df))
            
            # Update status
            self.root.after(0, lambda: self.status_var.set("Ready"))
            
        except Exception as e:
            error_msg = str(e)
            self.root.after(0, lambda: messagebox.showerror("Error", f"An error occurred: {error_msg}"))
            self.root.after(0, lambda: self.status_var.set("Error"))
    
    def nl_to_sql(self, natural_language_query):
        """Convert natural language to SQL using GPT-4o-mini"""
        try:
            # Get database schema information
            schema_info = self.get_db_schema()
            
            # Set up the prompt for GPT-4o-mini
            prompt = f"""
            You are an SQL expert that converts natural language queries to valid MySQL SQL statements.
            
            DATABASE SCHEMA:
            {schema_info}
            
            INSTRUCTIONS:
            - Generate a valid MySQL SELECT query only (no data modification queries)
            - Include appropriate JOINs if needed
            - Add a LIMIT clause if not specified in the question
            - Return ONLY the SQL query without any explanation or additional text
            
            USER QUERY: {natural_language_query}
            
            SQL:
            """
            
            # Call GPT-4o-mini
            client = openai.OpenAI(api_key=self.openai_api_key)
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system", "content": "You generate SQL queries from natural language. Reply with ONLY the SQL query."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0,
                max_tokens=500
            )
            
            # Extract SQL from response
            generated_sql = response.choices[0].message.content.strip()
            
            # Clean up the response (remove backticks, etc.)
            generated_sql = re.sub(r'^```sql\s*', '', generated_sql)
            generated_sql = re.sub(r'\s*```$', '', generated_sql)
            
            return generated_sql
            
        except Exception as e:
            raise Exception(f"Failed to convert natural language to SQL: {str(e)}")
    
    def get_db_schema(self):
        """Get database schema information for context"""
        try:
            conn = mysql.connector.connect(**self.db_config)
            cursor = conn.cursor()
            
            # Get list of tables
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            
            schema_info = []
            
            # Get columns for each table
            for table in tables:
                table_name = table[0]
                cursor.execute(f"DESCRIBE {table_name}")
                columns = cursor.fetchall()
                
                column_info = []
                for col in columns:
                    col_name = col[0]
                    col_type = col[1]
                    column_info.append(f"{col_name} ({col_type})")
                
                schema_info.append(f"Table: {table_name}\nColumns: {', '.join(column_info)}\n")
            
            cursor.close()
            conn.close()
            
            return "\n".join(schema_info)
            
        except Exception as e:
            raise Exception(f"Failed to get database schema: {str(e)}")
    
    def validate_sql(self, sql_query):
        """Validate SQL for safety"""
        sql_upper = sql_query.upper()
        
        # Check for blacklisted commands
        for cmd in self.sql_blacklist:
            if cmd in sql_upper and not f"'{cmd}" in sql_upper and not f'"{cmd}' in sql_upper:
                messagebox.showerror("Security Error", 
                                    f"For security reasons, {cmd} commands are not allowed.")
                return False
        
        # Ensure the query is a SELECT statement
        if not sql_upper.strip().startswith("SELECT"):
            messagebox.showerror("Security Error", 
                                "Only SELECT queries are allowed for security reasons.")
            return False
        
        # Ensure no multiple statements (no semicolons except at the end)
        if ";" in sql_query[:-1]:
            messagebox.showerror("Security Error", 
                                "Multiple SQL statements are not allowed.")
            return False
        
        return True
    
    def execute_sql(self, sql_query):
        """Execute SQL query on MySQL database"""
        try:
            conn = mysql.connector.connect(**self.db_config)
            
            # Execute query and convert to pandas DataFrame
            df = pd.read_sql_query(sql_query, conn)
            conn.close()
            
            return df
            
        except Exception as e:
            raise Exception(f"Failed to execute SQL query: {str(e)}")
    
    def display_results(self, df):
        """Display results in the treeview"""
        # Clear existing data
        for item in self.result_tree.get_children():
            self.result_tree.delete(item)
        
        # Configure columns
        columns = list(df.columns)
        self.result_tree["columns"] = columns
        
        # Configure headings
        self.result_tree["show"] = "headings"
        for col in columns:
            self.result_tree.heading(col, text=col)
            self.result_tree.column(col, width=100)
        
        # Add data rows
        for _, row in df.iterrows():
            values = list(row)
            self.result_tree.insert("", tk.END, values=values)
    
    def generate_chart(self, df):
        """Generate appropriate chart for the data"""
        # Clear current chart
        for widget in self.chart_frame.winfo_children():
            widget.destroy()
        
        # Check if we have data and it's suitable for visualization
        if df.empty or len(df.columns) < 2:
            ttk.Label(self.chart_frame, text="No data available for visualization").pack(expand=True)
            return
        
        try:
            # Create figure and axis
            fig, ax = plt.subplots(figsize=(10, 6))
            
            # Create a default chart based on the data
            if len(df) <= 10:  # Small number of rows - bar chart
                if df.shape[1] == 2:  # Two columns (category and value)
                    x_col = df.columns[0]
                    y_col = df.columns[1]
                    df.plot(kind='bar', x=x_col, y=y_col, ax=ax, legend=False)
                    ax.set_ylabel(y_col)
                else:  # More than two columns - select numeric columns for multi-bar
                    numeric_cols = df.select_dtypes(include=['number']).columns.tolist()
                    if numeric_cols:
                        non_numeric_cols = [col for col in df.columns if col not in numeric_cols]
                        if non_numeric_cols:
                            x_col = non_numeric_cols[0]
                            df.plot(kind='bar', x=x_col, y=numeric_cols[:3], ax=ax)
                        else:
                            df.plot(kind='bar', ax=ax)
            else:  # More rows - line chart if there seems to be a trend
                numeric_cols = df.select_dtypes(include=['number']).columns.tolist()
                if df.shape[1] >= 2 and numeric_cols:
                    # Check if first column might be a date or category for x-axis
                    x_col = df.columns[0]
                    y_cols = numeric_cols
                    df.plot(kind='line', x=x_col, y=y_cols[:3], ax=ax, marker='o')
            
            ax.set_title("Query Results Visualization")
            plt.tight_layout()
            
            # Embed the plot in the chart frame
            canvas = FigureCanvasTkAgg(fig, master=self.chart_frame)
            canvas.draw()
            canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)
            
        except Exception as e:
            ttk.Label(self.chart_frame, text=f"Failed to generate chart: {str(e)}").pack(expand=True)
    
    def generate_summary(self, query, sql_query, df):
        """Generate summary of the query results using GPT-4o-mini"""
        try:
            # If we don't have any data, return a simple message
            if df.empty:
                return "No data found for your query."
            
            # Get data statistics
            row_count = len(df)
            col_count = len(df.columns)
            
            # Create a summary of the data
            data_sample = df.head(5).to_string()
            data_stats = df.describe().to_string() if not df.empty else "No data"
            
            # Set up the prompt for GPT-4o-mini
            prompt = f"""
            Analyze the following database query and results:
            
            Natural Language Query: {query}
            SQL Query: {sql_query}
            
            Data sample (first 5 rows):
            {data_sample}
            
            Data statistics:
            {data_stats}
            
            Total rows returned: {row_count}
            
            Please provide a concise, meaningful summary of these results in 3-4 sentences. 
            Focus on key insights, patterns, or notable findings in the data.
            """
            
            # Call GPT-4o-mini for summary
            client = openai.OpenAI(api_key=self.openai_api_key)
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system", "content": "You provide concise, insightful summaries of database query results."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.5,
                max_tokens=200
            )
            
            # Extract summary from response
            summary = response.choices[0].message.content.strip()
            
            return summary
            
        except Exception as e:
            return f"Failed to generate summary: {str(e)}"
    
    def use_example(self, event):
        """Fill the query text box with the selected example"""
        example = self.example_var.get()
        self.query_text.delete("1.0", tk.END)
        self.query_text.insert(tk.END, example)
    
    def clear_query(self):
        """Clear the query text box"""
        self.query_text.delete("1.0", tk.END)
    
    def show_about(self):
        """Show about dialog"""
        messagebox.showinfo("About NL2SQL Query System", 
                           "Natural Language to SQL Query System\n\n"
                           "This application allows you to query MySQL databases "
                           "using natural language. It converts your questions into "
                           "SQL queries using OpenAI's GPT-4o-mini model.\n\n"
                           "Configure your database connection and API key in the "
                           "settings to get started.")

if __name__ == "__main__":
    root = tk.Tk()
    app = NL2SQLApp(root)
    root.mainloop()
