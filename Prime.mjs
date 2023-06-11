export function Prime(n) {
    if (n === 1) return false;
    if (n === 2) return true;
    if (n % 2 === 0) return false;

    let i = 1;

    while (true) {
        i += 2;
        if (i >= n) return true;
        if (i % n === 0) return false;
    }
}
