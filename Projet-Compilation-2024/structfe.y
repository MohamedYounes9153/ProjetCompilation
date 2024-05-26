%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
typedef enum {INTEGER, VOID1} type_t;

typedef struct _symbole_t{
        char *name;
        type_t type;
        int pos_t;
        int pos_p;
        struct _symbole_t *head_s;
        struct _symbole_t *next_s;
        struct _symbole_t *prev_p;
} symbole_t;

typedef struct _pile{
        symbole_t *head;
}pile;

symbole_t* st_init();

void st_add(symbole_t *, char *, type_t);

void st_free(symbole_t *);

symbole_t* st_search(symbole_t *, char *);

void push(symbole_t *, pile *);

void pop(pile *);

symbole_t* p_search(pile *, char *);

void p_free(pile *);

%}
%token <name> IDENTIFIER 
%token <val> CONSTANT
%token SIZEOF
%token PTR_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token EXTERN
%token INT VOID
%token STRUCT 
%token IF ELSE WHILE FOR RETURN
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%nonassoc PTRVAL

%union { int val;
        char *name;
}

%start program
%%

primary_expression
        : IDENTIFIER {$$ = $1.name;}
        | CONSTANT {$$ = $1.val;}
        | '(' expression ')'
        ;

postfix_expression
        : primary_expression
        | postfix_expression '(' ')'
        | postfix_expression '(' argument_expression_list ')'
        | postfix_expression '.' IDENTIFIER
        | postfix_expression PTR_OP IDENTIFIER
        ;

argument_expression_list
        : expression
        | argument_expression_list ',' expression
        ;

unary_expression
        : postfix_expression
        | unary_operator unary_expression
        | SIZEOF unary_expression
        ;

unary_operator
        : '&'
        | '*' %prec PTRVAL
        | '-' %prec UMINUS
        ;

multiplicative_expression
        : unary_expression
        | multiplicative_expression '*' unary_expression
        | multiplicative_expression '/' unary_expression
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression
        | additive_expression '-' multiplicative_expression
        ;

relational_expression
        : additive_expression
        | relational_expression '<' additive_expression
        | relational_expression '>' additive_expression
        | relational_expression LE_OP additive_expression
        | relational_expression GE_OP additive_expression
        ;

equality_expression
        : relational_expression
        | equality_expression EQ_OP relational_expression
        | equality_expression NE_OP relational_expression
        ;

logical_and_expression
        : equality_expression
        | logical_and_expression AND_OP equality_expression
        ;

logical_or_expression
        : logical_and_expression
        | logical_or_expression OR_OP logical_and_expression
        ;

expression
        : logical_or_expression
        | unary_expression '=' expression
        ;

declaration
        : declaration_specifiers declarator ';'
        | struct_specifier ';'
        ;

declaration_specifiers
        : EXTERN type_specifier
        | type_specifier
        ;

type_specifier
        : VOID
        | INT
        | struct_specifier
        ;

struct_specifier
        : STRUCT IDENTIFIER '{' struct_declaration_list '}'
        | STRUCT '{' struct_declaration_list '}'
        | STRUCT IDENTIFIER
        ;

struct_declaration_list
        : struct_declaration
        | struct_declaration_list struct_declaration
        ;

struct_declaration
        : type_specifier declarator ';'
        ;

declarator
        : '*' direct_declarator
        | direct_declarator
        ;

direct_declarator
        : IDENTIFIER
        | '(' declarator ')'
        | direct_declarator '(' parameter_list ')'
        | direct_declarator '(' ')'
        ;

parameter_list
        : parameter_declaration
        | parameter_list ',' parameter_declaration
        ;

parameter_declaration
        : declaration_specifiers declarator
        ;

statement
        : compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement 
        ;

compound_statement
        : '{' '}'
        | '{' statement_list '}'
        | '{' declaration_list '}'
        | '{' declaration_list statement_list '}'
        ;

declaration_list
        : declaration
        | declaration_list declaration
        ;

statement_list
        : statement
        | statement_list statement
        ;

expression_statement
        : ';'
        | expression ';'
        ;

selection_statement
        : IF '(' expression ')' statement
        | IF '(' expression ')' statement ELSE statement
        ;

iteration_statement
        : WHILE '(' expression ')' statement
        | FOR '(' expression_statement expression_statement expression ')' statement
        ;

jump_statement
        : RETURN ';'
        | RETURN expression ';'
        ;

program
        : external_declaration
        | program external_declaration
        ;

external_declaration
        : function_definition
        | declaration
        ;

function_definition
        : declaration_specifiers declarator compound_statement
        ;

%%

symbole_t* st_init(){
        symbole_t *st = (symbole_t *) calloc(1, sizeof(symbole_t));
        assert(st != NULL);
        return st;
}

void st_add(symbole_t *st, char *name, type_t type){
        symbole_t *new_st;
        int pos_t;
        if(st == NULL){
                fprintf(stderr, "Error : st is null pointer st_add\n");
                return;
        }
                if(name==NULL){
                fprintf(stderr,"Error : name is null pointer st_add\n");
                return;
        }
        if(st->next_s == NULL && st->pos_t == 0 && st->name == NULL && st->head_s == NULL){
                st->name = strdup(name);
                st->type = type;
                st->head_s = st;
        }
        else if (st->next_s == NULL){
                new_st = st_init();
                new_st->name = strdup(name);
                new_st->type = type;
                new_st->pos_t=(st->pos_t)+1;
                new_st->head_s = st->head_s;
                st->next_s = new_st;
        }
        else{
                st_add(st->next_s, name, type);
        }
}

void st_free(symbole_t *st){
        symbole_t *current = st;
        symbole_t *next;
        symbole_t *temp;
        if(st == NULL){
                fprintf(stderr, "Error : st is null pointer st_free\n");
                return;
        }
        if(st->head_s != NULL){
                current = st->head_s;
        }
        while(current->next_s != NULL){
                next = current->next_s;
                free(current->name);
                temp = current;
                free(temp);
                current = next;
        }
        free(current->name);
        free(current->head_s);
        free(current->prev_p);
        free(current);
}

symbole_t* st_search(symbole_t *st, char *name){
        symbole_t *current = st->head_s;
        if(name==NULL){
                fprintf(stderr,"Error : name is null pointer st_search\n");
                return NULL;
        }
        if(st==NULL){
                fprintf(stderr,"Error : st is null pointer st_search\n");
                return NULL;
        }
        while(current != NULL){
                if(strcmp(current->name, name) == 0){
                        return current;
                }
                current = current->next_s;
        }
        return NULL;
}

void push(symbole_t *st, pile *p){
        if(st==NULL){
                fprintf(stderr,"Error : st is null pointer push\n");
                return;
        }
        if(p==NULL){
                fprintf(stderr,"Error : p is null pointer push\n");
                return;
        }
        (st->head_s != NULL) ? st->head_s->prev_p = p->head; : st->prev_p = p->head;
        st->pos_p = (p->head != NULL) ? (p->head->pos_p)+1 : 0;
        p->head = st;
}

void pop(pile *p){
        if(p==NULL){
                fprintf(stderr,"Error : p is null pointer pop\n");
                return;
        }
        symbole_t *temp = (p->head != NULL) ? p->head->prev_p : NULL;
        free(p->head);
        p->head = temp;
}

symbole_t* p_search(pile *p, char *name){
        symbole_t *current;
        symbole_t *res = NULL;
        if(p==NULL){
                fprintf(stderr,"Error : p is null pointer p_search\n");
                return NULL;
        }
        current = p->head;
        while(current != NULL && current->pos_p >= 0 && res == NULL){
                res = st_search(current, name);
                current = current->prev_p;
        }
        return res;
}

void p_free(pile *p){
        if(p==NULL){
                fprintf(stderr,"Error : p is null pointer p_free\n");
                return;
        }
        while (p->head != NULL){
                pop(p);
        }
        free(p);
}

void main(){
        pile p = (pile *) calloc(1,sizeof(pile)); /* Création de la pile de tableaux de symboles*/
        assert(p != NULL);
        t= st_init();
        assert(t != NULL);
        yyparse();
        return (0);
}