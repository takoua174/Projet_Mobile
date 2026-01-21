import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MovieRow } from './movie-row';

describe('MovieRow', () => {
  let component: MovieRow;
  let fixture: ComponentFixture<MovieRow>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MovieRow]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MovieRow);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
