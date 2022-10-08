import datasets 
import pandas as pd


def europarl_sample(lang1, lang2, nSample = 0):
    testdata = datasets.load_dataset('europarl_bilingual', lang1=lang1, lang2=lang2, split = 'train', 
                                                cache_dir='datasets/temp')

    df_pandas = testdata.to_pandas()
    pd.set_option('display.max_colwidth', None)
    #print(df_pandas.head(n = 5))
    #print(df_pandas.shape[0])
    df_norm = df_pandas.join(pd.json_normalize(df_pandas.translation))
    df_norm.drop(columns=['translation'], inplace=True)
    df_norm.reset_index(inplace=True)

    #print(df_norm.head(n = 3))
    #print(df_norm.columns)

    if (nSample > 0):
        df_sample = df_norm.sample(n = nSample)
        return(df_sample)
    else: 
        return(df_norm)

    

#print(df_sample.shape)


#print (type(df_pandas))
