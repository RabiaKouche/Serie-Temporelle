
FloatTable donnees;
float dmin, dmax;
int amin, amax;
int[] annees;
float traceX1, traceY1, traceX2, traceY2;

// La colonne de données actuellement utilisée.
int colonne = 0;
// Le nombre de colonnes.
int ncol;
// La police de caractères.
PFont police;
Integrator[] interp;

int intervalleAnnees;
int intervalleVolume = 10;
int intervalleVolumeMineur = 5;
int lignes;
String []afficheMode = {"ligne", "Aire", "Histogramme"};
int mode = 0;

void setup() {
  size(970, 605);

  donnees = new FloatTable("lait-the-cafe.tsv");
  dmin = 0;
  dmax = ceil(donnees.getTableMax() / intervalleVolume) * intervalleVolume;
  ncol = donnees.getColumnCount();
  annees = int(donnees.getRowNames());
  intervalleAnnees = 10;
  amin = annees[0];
  amax = annees[annees.length - 1];
  traceX1 = 120;
  traceY1 = 50;
  traceX2 = width - 50;
  traceY2 = height - 70;
  police = createFont("SansSerif", 20);
  textFont(police);
  lignes = donnees.getRowCount();
  interp = new Integrator[lignes];

  for (int ligne = 0; ligne <lignes; ligne++) {
    interp[ligne] = new Integrator(donnees.getFloat(ligne, colonne), 0.4, 0.1);
  }

  smooth();
}



void draw() {
  background(224);

  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(traceX1, traceY1, traceX2, traceY2);
  dessineTitre();
  dessinerXtitre();
  dessinerYtitre();
  dessineAxeAnnees();
  dessineAxeVolume();
  dessineDonnees(mode, colonne);
}


void dessineTitre() {
  fill(0);
  textSize(25);
  textAlign(LEFT);
  text(donnees.getColumnName(colonne), traceX1, traceY1 - 10);
}

void dessinerXtitre() {
  fill(0);
  textSize(16);
  textAlign(CENTER);
  text("Année", traceX2/2 + traceX1/2, traceY2+50);
}


void dessinerYtitre() {

  fill(0);
  textSize(16);
  text("Litres\n consommés par\n pers", traceX1/2, traceY2/2);
}


void dessineDonnees(int mode, int col) {

  switch(mode) {
  case 0 :  
    dessineLigneDonnees(col);
    dessinePointsDonnees(col);
    return;
  case 1 : 
    dessineAireDonnees(col);
    return;
  case 2 : 
    dessineHistoDonnees(col);
    return;
  }
}

void dessineHistoDonnees(int col) {

  strokeWeight(3);
  stroke(#5679C1);
  int lignes = donnees.getRowCount();


  for (int ligne = 0; ligne <lignes; ligne++) {
    interp[ligne].update();

    if (donnees.isValid(ligne, col)) {
      float valeur =interp[ligne].value;
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      float y = map(valeur, dmin, dmax, traceY2, traceY1);

      rect(x, y, x, traceY2);
    }
  }
}

void dessineAireDonnees(int col) {
  int lignes = donnees.getRowCount();
  beginShape();
  fill(#5679C1);
  vertex(traceX1, traceY2);
  for (int ligne = 0; ligne< lignes; ligne++) {
    interp[ligne].update();

    if (donnees.isValid(ligne, col)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      float y = map(valeur, dmin, dmax, traceY2, traceY1);
      vertex(x, y);
    }
  }
  vertex(traceX2, traceY2);
  endShape();
  dessineAxeAnnees();
}

void dessineLigneDonnees(int col) {
  strokeWeight(1);
  stroke(#5679C1);
  noFill();

  beginShape(); 
  int lignes = donnees.getRowCount();
  for (int ligne = 0; ligne < lignes; ligne++) {
    interp[ligne].update();

    if (donnees.isValid(ligne, col)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      float y = map(valeur, dmin, dmax, traceY2, traceY1);
      //point(x, y);
      vertex(x, y);
    }
  }
  endShape(); // On termine la ligne sans fermer la forme.
}


void dessinePointsDonnees(int col) {
  strokeWeight(5);
  stroke(#5679C1);
  int lignes = donnees.getRowCount();
  for (int ligne = 0; ligne < lignes; ligne++) {
    interp[ligne].update();

    if (donnees.isValid(ligne, col)) {
      float valeur = interp[ligne].value;
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      float y = map(valeur, dmin, dmax, traceY2, traceY1);
      point(x, y);
    }
  }
}

void dessineAxeAnnees() {
  fill(0);
  textSize(14);
  textAlign(CENTER, TOP);

  stroke(224);
  strokeWeight(1);

  int lignes = donnees.getRowCount();
  for (int ligne = 0; ligne < lignes; ligne++) {
    if (annees[ligne] % intervalleAnnees == 0) {
      float x = map(annees[ligne], amin, amax, traceX1, traceX2);
      text(annees[ligne], x, traceY2 + 10);
      line(x, traceY2, x, traceY1);
    }
  }
}

void dessineAxeVolume() {
  fill(0);
  textSize(14);
  stroke(128);
  strokeWeight(1);

  for (float v = dmin; v <= dmax; v+=intervalleVolumeMineur) {
    if (v % intervalleVolumeMineur == 0) {
      float y = map(v, dmin, dmax, traceY2, traceY1);
      if (v % intervalleVolume == 0) {
        if (v == dmin) {
          textAlign(RIGHT, BOTTOM);
        } else if (v == dmax) {
          textAlign(RIGHT, TOP);
        } else {
          textAlign(RIGHT, CENTER);
        }
        text(floor(v), traceX1 - 10, y);
        line(traceX1 - 4, y, traceX1, y); // Tiret majeur.
      } else {
        line(traceX1 - 2, y, traceX1, y); // Tiret mineur.
      }
    }
  }
}


void keyPressed() {

  if (key == CODED) {

    if (keyCode == LEFT) {
      colonne = colonne == 0 ? ncol - 1 : --colonne;
      for (int ligne = 0; ligne < lignes; ligne++) {
        interp[ligne].target(donnees.getFloat(ligne, colonne));
      }
    }

    if (keyCode == RIGHT) {
      colonne = colonne == ncol - 1 ? 0 : ++colonne;
      for (int ligne = 0; ligne < lignes; ligne++) {
        interp[ligne].target(donnees.getFloat(ligne, colonne));
      }
      
    }
    if(keyCode == UP){
 
     mode = mode ==afficheMode.length -1 ? 0 : ++mode;
    }
    if(keyCode == DOWN){
     mode = mode == 0 ? afficheMode.length -1 : --mode;

    }
    
    
    
  }
}
