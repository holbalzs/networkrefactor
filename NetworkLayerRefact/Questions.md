#  Some question

- (ha marad időm) socketnél jó ez hogy most closer rel vissza szolok ha megfrissült a token, ugye ott nincs ilyen auth refresh
- nem akarom csak custom hibákat le kezelni külön külön a viewmodelben meghívott api val, pl rfresh token lejáratnak a hibáját egyszer akarom kezelni, hogy dobjon login képernyőre  
- hogy lehetne szépen berakni a serviceket/ composition root ot, itt nem tudom scene delegateben structban lazy var nincs, stateobject be nem sikerült paraméterként bevinni
- init(networkManager: NetworkManager) érdemes mindig ezt át adni vagy inkább hozzuk létre composition rootban a servicet lazy var ral pl.: UserResourceService(networkManager: networkManager) és akkor userresource servicet adjunk át viewmodelnek?
