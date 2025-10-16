import pandas as pd
from lexicalrichness import LexicalRichness
import spacy

# === Load spaCy for POS tagging ===
nlp = spacy.load("en_core_web_sm")

# === Load COCA frequency list ===
# Your CSV has columns: rank, lemma, PoS, freq, ...
coca = pd.read_csv("COCA_WordFrequency.csv", encoding="utf-8")  # tab-separated
coca["lemma"] = coca["lemma"].str.lower()

# Create a dictionary: lemma -> rank
coca_rank_dict = dict(zip(coca["lemma"], coca["rank"]))

# === Functions ===

# 1. MLTD
def compute_mltd(text):
    if not isinstance(text, str) or not text.strip():
        return None
    lex = LexicalRichness(text)
    return lex.mtld()

# 2. Lexical Density
def compute_lexical_density(text):
    if not isinstance(text, str) or not text.strip():
        return None
    doc = nlp(text)
    tokens = [t for t in doc if t.is_alpha]
    if not tokens:
        return None
    content_words = [t for t in tokens if t.pos_ in ["NOUN", "VERB", "ADJ", "ADV"]]
    return len(content_words) / len(tokens)

# 3. Lexical Sophistication
def compute_lexical_sophistication(text, top_n=2000):
    """
    Proportion of words NOT in the top_n most frequent COCA lemmas
    """
    if not isinstance(text, str) or not text.strip():
        return None
    
    words = [w.lower() for w in text.split() if w.isalpha()]
    if not words:
        return None

    top_words = set([w for w, r in coca_rank_dict.items() if r <= top_n])
    low_freq_words = [w for w in words if w not in top_words]
    return len(low_freq_words) / len(words)

# === Load your essays CSV ===
# CSV must have columns: PID, Essay1, Essay2, Essay3
df = pd.read_csv("MulDiLoC-HAP.csv")

# Prepare results list
results = []

# === Compute measures for each essay ===
for idx, row in df.iterrows():
    pid = row["PID"]
    for essay_col in ["Essay1", "Essay2", "Essay3"]:
        text = row.get(essay_col, "")
        mltd = compute_mltd(text)
        density = compute_lexical_density(text)
        sophistication = compute_lexical_sophistication(text)
        
        results.append({
            "PID": pid,
            "Essay": essay_col,
            "MLTD": mltd,
            "LexicalDensity": density,
            "LexicalSophistication": sophistication
        })

# === Save results to CSV ===
out_df = pd.DataFrame(results)
out_df.to_csv("lexical_measures.csv", index=False)

print("Done! Results saved to 'essay_measures.csv'.")
