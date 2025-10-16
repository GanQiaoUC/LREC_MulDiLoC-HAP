import spacy
import pandas as pd
import re
from scipy.stats import entropy

# Load spaCy
nlp = spacy.load("en_core_web_sm")

def analyze_essay(text):
    """Analyze a single essay and return syntactic measures."""
    if not isinstance(text, str) or not text.strip():
        return {
            "MeanClauseLength": 0,
            "AvgDepLength": 0,
            "DepTypeEntropy": 0,
            "NominalDensity": 0,
            "NPComplexity": 0,
            "VPComplexity": 0,
            "MeanNPLength": 0,
            "PPDensity": 0
        }

    text = re.sub(r"\s+", " ", text)
    doc = nlp(text)
    
    if len(doc) == 0:
        return {
            "MeanClauseLength": 0,
            "AvgDepLength": 0,
            "DepTypeEntropy": 0,
            "NominalDensity": 0,
            "NPComplexity": 0,
            "VPComplexity": 0,
            "MeanNPLength": 0,
            "PPDensity": 0
        }

    # 1. Dependency length
    dep_lengths = [abs(tok.i - tok.head.i) for tok in doc if tok.dep_ != "ROOT"]
    avg_dep_length = sum(dep_lengths) / len(dep_lengths) if dep_lengths else 0

    # 2. Dependency type entropy (diversity)
    dep_counts = pd.Series([tok.dep_ for tok in doc]).value_counts(normalize=True)
    dep_entropy = entropy(dep_counts.values) if len(dep_counts) > 0 else 0

    # 3. Mean clause length (including subordinate clauses)
    num_sents = len(list(doc.sents))
    num_subordinate = sum(1 for tok in doc if tok.dep_ in ['ccomp', 'xcomp', 'advcl', 'acl', 'relcl'])
    total_clauses = num_sents + num_subordinate
    mean_clause_length = len(doc) / total_clauses if total_clauses > 0 else 0

    # 4. NP measures
    nps = list(doc.noun_chunks)
    
    # Mean NP length
    np_lengths = [len(list(chunk)) for chunk in nps]
    mean_np_length = sum(np_lengths) / len(np_lengths) if np_lengths else 0
    
    # NP complexity (internal structure)
    np_complexity_scores = []
    for chunk in nps:
        complexity = sum(1 for tok in chunk if tok.dep_ in ['amod', 'compound', 'prep', 'relcl', 'acl', 'nummod'])
        np_complexity_scores.append(complexity)
    np_complexity = sum(np_complexity_scores) / len(np_complexity_scores) if np_complexity_scores else 0

    # 5. VP complexity (size of verb phrases)
    vp_sizes = []
    for tok in doc:
        if tok.pos_ == "VERB":
            # Count all tokens in the VP (verb + descendants)
            vp_size = len([t for t in tok.subtree if t.pos_ != "PUNCT"])
            vp_sizes.append(vp_size)
    vp_complexity = sum(vp_sizes) / len(vp_sizes) if vp_sizes else 0

    # 6. PP density (prepositional phrases per sentence)
    num_pps = sum(1 for tok in doc if tok.pos_ == "ADP")
    pp_density = num_pps / num_sents if num_sents > 0 else 0

    # 7. Nominalization density (per 100 words)
    nominalizations = [
        tok for tok in doc 
        if tok.pos_ == "NOUN" 
        and re.search(r"(tion|sion|ment|ness|ity|ance|ence|ancy|ency|ship|ism|acy|ure|al|age|ery|ry)$", 
                     tok.text.lower())
    ]
    nominal_density = (len(nominalizations) / len(doc)) * 100 if len(doc) > 0 else 0

    return {
        "MeanClauseLength": mean_clause_length,
        "AvgDepLength": avg_dep_length,
        "DepTypeEntropy": dep_entropy,
        "NominalDensity": nominal_density,
        "NPComplexity": np_complexity,
        "VPComplexity": vp_complexity,
        "MeanNPLength": mean_np_length,
        "PPDensity": pp_density
    }

# Load CSV
df = pd.read_csv("MulDiLoC-HAP.csv")

results = []
for idx, row in df.iterrows():
    for essay_col in ["Essay1", "Essay2", "Essay3"]:
        if pd.notnull(row[essay_col]) and str(row[essay_col]).strip():
            measures = analyze_essay(row[essay_col])
            measures["PID"] = row["PID"]
            measures["Essay"] = essay_col
            results.append(measures)

# Save results
out = pd.DataFrame(results)
out.to_csv("syntactic_measures.csv", index=False)
print("Analysis complete! Results saved to syntactic_measures.csv")
