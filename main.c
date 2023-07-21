#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define auto __auto_type

#define max(A, B)                                                              \
    ({                                                                         \
        auto _a = (A);                                                         \
        auto _b = (B);                                                         \
        _a > _b ? _a : _b;                                                     \
    })

typedef struct {
    char *ptr;
    size_t len;
} Str;

typedef struct {
    union {
        Str str;
        struct {
            char *ptr;
            size_t len;
        };
    };
    size_t cap;
} String;

typedef struct {
    void **items;
    size_t len;
    size_t cap;
} Vec;

static Str str_trim_start_spaces(Str str) {
    while (str.len > 0 && *str.ptr == ' ') {
        str.ptr++;
        str.len--;
    }
    return str;
}

static void vec_push(Vec *vec, void *item) {
    if (vec->len == vec->cap) {
        vec->cap = max(vec->cap * 2, (size_t)4);
        vec->items = realloc(vec->items, vec->cap * sizeof(void *));
    }
    vec->items[vec->len++] = item;
}

static void show_prompt(void) {
    fputs("> ", stdout);
    fflush(stdout);
}

static bool read_line(String *line) {
    line->len = getline(&line->ptr, &line->cap, stdin);
    if (line->len == (size_t)-1) {
        return false;
    }
    if (line->ptr[line->len - 1] == '\n') {
        line->ptr[line->len - 1] = '\0';
        --line->len;
    }
    return true;
}

static void lex_line(Str line, Vec *tokens) {
    tokens->len = 0;
    line.ptr[line.len] = ' ';
    for (char *next_space;
         line = str_trim_start_spaces(line),
         line.len > 0 && (next_space = memchr(line.ptr, ' ', line.len + 1));) {
        size_t token_len = next_space - line.ptr;
        vec_push(tokens, line.ptr);
        *next_space = '\0';
        line.ptr += token_len + 1;
        line.len -= token_len + 1;
    }
}

static void interpret(Vec *tokens) {
    if (tokens->len == 0) {
        return;
    }
    pid_t child = fork();
    if (child == 0) {
        vec_push(tokens, NULL);
        execvp(tokens->items[0], (char **)tokens->items);
    } else {
        waitpid(child, NULL, 0);
    }
}

int main(void) {
    bool is_interactive = isatty(STDIN_FILENO);
    String line = {};
    Vec tokens = {};

    for (;;) {
        if (is_interactive) {
            show_prompt();
        }
        if (!read_line(&line)) {
            break;
        }
        lex_line(line.str, &tokens);
        interpret(&tokens);
    }

    free(tokens.items);
    free(line.ptr);
}
